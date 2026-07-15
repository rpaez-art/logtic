package com.example.logtic.ui.screens

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.text.Html
import android.util.Base64
import android.widget.Toast
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ExitToApp
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import com.example.logtic.data.Route
import com.example.logtic.data.RouteStatus
import com.example.logtic.data.api.AttachmentData
import com.example.logtic.ui.components.PhotoCaptureDialog
import com.example.logtic.ui.theme.*
import com.example.logtic.viewmodel.AuthViewModel
import com.example.logtic.viewmodel.OdooViewModel
import com.example.logtic.viewmodel.RouteFilter
import com.example.logtic.viewmodel.RouteViewModel
import com.google.android.gms.location.LocationServices
import java.io.File
import java.io.FileOutputStream
import java.net.URLEncoder

// Función helper para formatear fecha/hora
fun formatDateTime(dateTimeStr: String): String {
    return try {
        // Formato esperado: "2025-11-13 14:30:45"
        val parts = dateTimeStr.split(" ")
        if (parts.size == 2) {
            val date = parts[0].split("-")
            val time = parts[1].split(":")
            "${date[2]}/${date[1]} ${time[0]}:${time[1]}"  // "13/11 14:30"
        } else {
            dateTimeStr
        }
    } catch (e: Exception) {
        dateTimeStr
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RoutesScreen(
    authViewModel: AuthViewModel,
    routeViewModel: RouteViewModel,
    odooViewModel: OdooViewModel,
    onLogout: () -> Unit,
    onManageUsers: () -> Unit,
    onMonitorDrivers: () -> Unit,
    onBackToDashboard: (() -> Unit)? = null
) {
    val context = LocalContext.current
    val isAdmin = authViewModel.currentUser.value?.username == "admin"
    
    // Sincronizar rutas desde Odoo al iniciar
    LaunchedEffect(key1 = authViewModel.currentUser.value) {
        if (!isAdmin) {
            // Usar driver_id directamente (ID del partner vinculado)
            val driverId = authViewModel.currentUser.value?.driverId
            // Solo sincronizar si hay un driver_id válido (mayor que 0)
            // Si es 0 o null, el servidor Odoo tiene un bug de serialización
            if (driverId != null && driverId > 0) {
                odooViewModel.syncRoutesFromOdoo(driverId) { odooRoutes ->
                    if (odooRoutes.isNotEmpty()) {
                        routeViewModel.setRoutesFromOdoo(odooRoutes)
                    }
                }
            } else {
                // Intentar sincronizar de todas formas pero con un driver_id por defecto
                // para evitar el error de serialización del servidor
                android.util.Log.w("RoutesScreen", "Driver ID no válido: $driverId, intentando sincronización general")
                odooViewModel.syncRoutesFromOdoo(driverId) { odooRoutes ->
                    if (odooRoutes.isNotEmpty()) {
                        routeViewModel.setRoutesFromOdoo(odooRoutes)
                    }
                }
            }
        }
    }
    
    Scaffold(
        topBar = {
            // TopAppBar con gradiente moderno
            Surface(
                modifier = Modifier.fillMaxWidth(),
                shadowElevation = 8.dp
            ) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(
                            Brush.horizontalGradient(
                                colors = listOf(
                                    LogticPrimaryGradientStart,
                                    LogticPrimaryGradientEnd
                                )
                            )
                        )
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                // Botón volver al Dashboard
                                if (onBackToDashboard != null) {
                                    IconButton(
                                        onClick = onBackToDashboard,
                                        modifier = Modifier
                                            .size(40.dp)
                                            .clip(CircleShape)
                                            .background(LogticWhite.copy(alpha = 0.2f))
                                    ) {
                                        Icon(
                                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                                            contentDescription = "Volver",
                                            tint = LogticWhite
                                        )
                                    }
                                }
                                
                                Column {
                                    Text(
                                        text = "Mis Rutas",
                                        fontSize = 24.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = LogticWhite
                                    )
                                    Spacer(modifier = Modifier.height(2.dp))
                                    Text(
                                        text = "${authViewModel.currentUser.value?.fullName ?: "Conductor"}",
                                        fontSize = 14.sp,
                                        color = LogticWhite.copy(alpha = 0.85f)
                                    )
                                }
                            }
                            
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                if (isAdmin) {
                                    IconButton(onClick = onMonitorDrivers) {
                                        Icon(
                                            imageVector = Icons.Default.Visibility,
                                            contentDescription = "Monitor",
                                            tint = LogticWhite
                                        )
                                    }
                                    IconButton(onClick = onManageUsers) {
                                        Icon(
                                            imageVector = Icons.Default.SupervisorAccount,
                                            contentDescription = "Usuarios",
                                            tint = LogticWhite
                                        )
                                    }
                                } else {
                                    IconButton(
                                        onClick = { 
                                            // Usar driver_id directamente
                                            val driverId = authViewModel.currentUser.value?.driverId
                                            odooViewModel.syncRoutesFromOdoo(driverId) { routes ->
                                                if (routes.isNotEmpty()) {
                                                    routeViewModel.setRoutesFromOdoo(routes)
                                                }
                                            }
                                        },
                                        enabled = !odooViewModel.isLoading.value
                                    ) {
                                        if (odooViewModel.isLoading.value) {
                                            CircularProgressIndicator(
                                                modifier = Modifier.size(24.dp),
                                                strokeWidth = 2.dp,
                                                color = LogticWhite
                                            )
                                        } else {
                                            Icon(
                                                imageVector = Icons.Default.Sync,
                                                contentDescription = "Sincronizar",
                                                tint = LogticWhite
                                            )
                                        }
                                    }
                                }
                                IconButton(onClick = onLogout) {
                                    Icon(
                                        imageVector = Icons.AutoMirrored.Filled.ExitToApp,
                                        contentDescription = "Salir",
                                        tint = LogticWhite
                                    )
                                }
                            }
                        }
                        
                        // Estado de conexión
                        Spacer(modifier = Modifier.height(8.dp))
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            ConnectionBadge(
                                isConnected = odooViewModel.isConnected.value,
                                lastSync = odooViewModel.lastSyncTime.value
                            )
                            
                            if (odooViewModel.errorMessage.value.isNotEmpty()) {
                                Surface(
                                    shape = RoundedCornerShape(12.dp),
                                    color = LogticError.copy(alpha = 0.3f)
                                ) {
                                    Text(
                                        text = "⚠️ Error",
                                        fontSize = 10.sp,
                                        color = LogticWhite,
                                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .background(MaterialTheme.colorScheme.background)
        ) {
            // Tarjetas de estadísticas con nuevos colores
            StatsCardsRow(
                totalRoutes = odooViewModel.odooRoutes.value.filter { it.state != "finished" }.sumOf { it.routeLines.size },
                inProgressCount = odooViewModel.odooRoutes.value.flatMap { it.routeLines }.count { it.state == "in_progress" || it.state == "picked_up" },
                completedCount = odooViewModel.odooRoutes.value.flatMap { it.routeLines }.count { it.state in listOf("done", "incomplete", "partial") }
            )
            
            // Lista de rutas
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
                contentPadding = PaddingValues(vertical = 16.dp)
            ) {
                // Agrupar rutas por nombre y filtrar las completadas
                val groupedRoutes = odooViewModel.odooRoutes.value
                    .filter { it.state != "finished" }
                    .groupBy { it.name }
                
                if (groupedRoutes.isEmpty()) {
                    item {
                        EmptyStateCard(
                            errorMessage = odooViewModel.errorMessage.value,
                            driverId = authViewModel.currentUser.value?.driverId
                        )
                    }
                } else {
                    groupedRoutes.forEach { (routeName, routeData) ->
                        item {
                            ModernExpandableRouteCard(
                                routeName = routeName,
                                routeLines = routeData.firstOrNull()?.routeLines ?: emptyList(),
                                routeData = routeData.firstOrNull(),
                                odooViewModel = odooViewModel,
                                context = context
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun ConnectionBadge(isConnected: Boolean, lastSync: String) {
    Surface(
        shape = RoundedCornerShape(12.dp),
        color = if (isConnected) LogticGreen.copy(alpha = 0.3f) else LogticError.copy(alpha = 0.3f)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(8.dp)
                    .clip(CircleShape)
                    .background(if (isConnected) LogticGreenLight else LogticError)
            )
            Text(
                text = if (isConnected) {
                    if (lastSync.isNotEmpty()) "Sync: $lastSync" else "Conectado"
                } else "Desconectado",
                fontSize = 11.sp,
                fontWeight = FontWeight.Medium,
                color = LogticWhite
            )
        }
    }
}

@Composable
fun StatsCardsRow(totalRoutes: Int, inProgressCount: Int, completedCount: Int) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 12.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = CorpDarkGray
        ),
        elevation = CardDefaults.cardElevation(6.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            StatCardItem(
                icon = Icons.Default.ListAlt,
                value = totalRoutes.toString(),
                label = "Pendientes",
                iconColor = CorpLightBlue
            )
            
            VerticalDivider(
                modifier = Modifier.height(50.dp),
                color = LogticWhite.copy(alpha = 0.2f)
            )
            
            StatCardItem(
                icon = Icons.Default.LocalShipping,
                value = inProgressCount.toString(),
                label = "En Curso",
                iconColor = CorpGold
            )
            
            VerticalDivider(
                modifier = Modifier.height(50.dp),
                color = LogticWhite.copy(alpha = 0.2f)
            )
            
            StatCardItem(
                icon = Icons.Default.CheckCircle,
                value = completedCount.toString(),
                label = "Completadas",
                iconColor = StatusCompleted
            )
        }
    }
}

@Composable
fun StatCardItem(
    icon: ImageVector,
    value: String,
    label: String,
    iconColor: androidx.compose.ui.graphics.Color
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = iconColor,
            modifier = Modifier.size(24.dp)
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = value,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = LogticWhite
        )
        Text(
            text = label,
            fontSize = 11.sp,
            color = LogticWhite.copy(alpha = 0.8f)
        )
    }
}

@Composable
fun EmptyStateCard(
    errorMessage: String = "",
    driverId: Int? = null
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = Icons.Default.LocalShipping,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                tint = MaterialTheme.colorScheme.primary.copy(alpha = 0.5f)
            )
            Spacer(modifier = Modifier.height(16.dp))
            
            if (errorMessage.isNotEmpty()) {
                // Mostrar mensaje de error
                Text(
                    text = "⚠️ Error de sincronización",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Medium,
                    color = LogticError
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = errorMessage,
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f),
                    textAlign = TextAlign.Center
                )
            } else {
                // Sin rutas pendientes
                Text(
                    text = "Sin rutas pendientes",
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Medium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "No hay entregas asignadas para hoy",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f)
                )
            }
            
            // Info de debug (solo visible en desarrollo)
            if (driverId != null) {
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = "Driver ID: $driverId",
                    fontSize = 10.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                )
            }
        }
    }
}

@Composable
fun RouteCard(
    route: Route,
    onNavigate: () -> Unit,
    onStartRoute: () -> Unit,
    onCompleteRoute: () -> Unit
) {
    // Este componente ya no se usa, reemplazado por ModernExpandableRouteCard
}

@Composable
fun ModernExpandableRouteCard(
    routeName: String,
    routeLines: List<com.example.logtic.data.api.RouteLineData>,
    routeData: com.example.logtic.data.api.RouteData?,
    odooViewModel: OdooViewModel,
    context: android.content.Context
) {
    var isExpanded by remember { mutableStateOf(false) }
    
    val completedCount = routeLines.count { it.state in listOf("done", "incomplete", "partial") }
    val totalCount = routeLines.size
    val progress = if (totalCount > 0) completedCount.toFloat() / totalCount else 0f
    
    // Detectar si la ruta tiene solicitudes urgentes (no completadas)
    val hasUrgentLines = routeLines.any { it.priority == "urgent" && it.state !in listOf("done", "cancelled", "incomplete", "partial") }
    val isUrgent = hasUrgentLines || (routeData?.maxPriority == "urgent" && routeData.state != "finished")
    
    // Animación de pulso infinito para rutas urgentes
    val infiniteTransition = rememberInfiniteTransition(label = "urgentPulse")
    val urgentAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(800, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "urgentAlpha"
    )
    val urgentScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.02f,
        animationSpec = infiniteRepeatable(
            animation = tween(800, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "urgentScale"
    )
    
    // Animaciones mejoradas
    val cardScale by animateFloatAsState(
        targetValue = if (isExpanded) 1f else 1f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow
        ),
        label = "cardScale"
    )
    
    val progressAnimation by animateFloatAsState(
        targetValue = progress,
        animationSpec = tween(
            durationMillis = 800,
            easing = FastOutSlowInEasing
        ),
        label = "progress"
    )
    
    val iconRotation by animateFloatAsState(
        targetValue = if (isExpanded) 180f else 0f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium
        ),
        label = "iconRotation"
    )
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .scale(if (isUrgent) urgentScale else cardScale)
            .then(
                if (isUrgent) Modifier
                    .background(
                        Brush.radialGradient(
                            colors = listOf(
                                LogticError.copy(alpha = urgentAlpha * 0.4f),
                                androidx.compose.ui.graphics.Color.Transparent
                            )
                        ),
                        shape = RoundedCornerShape(22.dp)
                    )
                else Modifier
            ),
        shape = RoundedCornerShape(20.dp),
        border = if (isUrgent) androidx.compose.foundation.BorderStroke(
            2.dp,
            LogticError.copy(alpha = urgentAlpha)
        ) else null,
        elevation = CardDefaults.cardElevation(
            defaultElevation = animateDpAsState(
                targetValue = if (isUrgent) 12.dp else if (isExpanded) 8.dp else 4.dp,
                animationSpec = spring(dampingRatio = Spring.DampingRatioLowBouncy),
                label = "elevation"
            ).value
        ),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier.fillMaxWidth()
        ) {
            // Header de la ruta
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { isExpanded = !isExpanded }
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = if (isUrgent) LogticError.copy(alpha = urgentAlpha) else LogticBlue
                        ) {
                            Icon(
                                imageVector = if (isUrgent) Icons.Default.Warning else Icons.Default.Route,
                                contentDescription = null,
                                tint = LogticWhite,
                                modifier = Modifier
                                    .padding(6.dp)
                                    .size(20.dp)
                            )
                        }
                        Text(
                            text = routeName,
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        if (isUrgent) {
                            Surface(
                                shape = RoundedCornerShape(6.dp),
                                color = LogticError.copy(alpha = urgentAlpha)
                            ) {
                                Text(
                                    text = "⚠ URGENTE",
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = LogticWhite,
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                                )
                            }
                        }
                    }
                    
                    Spacer(modifier = Modifier.height(8.dp))
                    
                    // Barra de progreso animada
                    Column {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                text = "$completedCount de $totalCount entregas",
                                fontSize = 12.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            Text(
                                text = "${(progressAnimation * 100).toInt()}%",
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Medium,
                                color = LogticGreenLight
                            )
                        }
                        Spacer(modifier = Modifier.height(4.dp))
                        LinearProgressIndicator(
                            progress = { progressAnimation },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(6.dp)
                                .clip(RoundedCornerShape(3.dp)),
                            color = LogticGreenLight,
                            trackColor = MaterialTheme.colorScheme.surfaceVariant
                        )
                    }
                    
                    // Fechas
                    if (routeData != null) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            if (!routeData.startDate.isNullOrEmpty()) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.PlayArrow,
                                        contentDescription = null,
                                        modifier = Modifier.size(14.dp),
                                        tint = LogticBlue
                                    )
                                    Text(
                                        text = formatDateTime(routeData.startDate),
                                        fontSize = 11.sp,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }
                            if (!routeData.endDate.isNullOrEmpty()) {
                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.CheckCircle,
                                        contentDescription = null,
                                        modifier = Modifier.size(14.dp),
                                        tint = LogticGreenLight
                                    )
                                    Text(
                                        text = formatDateTime(routeData.endDate),
                                        fontSize = 11.sp,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }
                        }
                    }
                }
                
                // Botón expandir con animación de rotación
                Surface(
                    shape = CircleShape,
                    color = MaterialTheme.colorScheme.primaryContainer
                ) {
                    Icon(
                        imageVector = Icons.Default.ExpandMore,
                        contentDescription = if (isExpanded) "Contraer" else "Expandir",
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier
                            .padding(8.dp)
                            .size(24.dp)
                            .graphicsLayer { rotationZ = iconRotation }
                    )
                }
            }
            
            // Lista de actividades expandible con animación mejorada
            AnimatedVisibility(
                visible = isExpanded,
                enter = expandVertically(
                    animationSpec = spring(
                        dampingRatio = Spring.DampingRatioLowBouncy,
                        stiffness = Spring.StiffnessLow
                    )
                ) + fadeIn(
                    animationSpec = tween(300)
                ),
                exit = shrinkVertically(
                    animationSpec = spring(
                        dampingRatio = Spring.DampingRatioNoBouncy,
                        stiffness = Spring.StiffnessMedium
                    )
                ) + fadeOut(
                    animationSpec = tween(200)
                )
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f))
                        .padding(12.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    routeLines.sortedBy { it.sequence }.forEachIndexed { index, line ->
                        // Animación de entrada escalonada
                        val itemAlpha by animateFloatAsState(
                            targetValue = if (isExpanded) 1f else 0f,
                            animationSpec = tween(
                                durationMillis = 300,
                                delayMillis = index * 50
                            ),
                            label = "itemAlpha$index"
                        )
                        
                        Box(
                            modifier = Modifier.graphicsLayer { alpha = itemAlpha }
                        ) {
                            ModernRouteActivityCard(
                                line = line,
                                odooViewModel = odooViewModel,
                                context = context
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun ModernRouteActivityCard(
    line: com.example.logtic.data.api.RouteLineData,
    odooViewModel: OdooViewModel,
    context: android.content.Context
) {
    val fusedLocationClient = remember { LocationServices.getFusedLocationProviderClient(context) }
    var showPhotoDialog by remember { mutableStateOf(false) }
    var showIncompleteDialog by remember { mutableStateOf(false) }
    var currentLocation by remember { mutableStateOf<Pair<Double?, Double?>>(null to null) }
    
    // Obtener ubicación actual
    LaunchedEffect(Unit) {
        if (ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            fusedLocationClient.lastLocation.addOnSuccessListener { location ->
                currentLocation = (location?.latitude to location?.longitude)
            }
        }
    }
    
    // Colores según estado
    val stateColor = when (line.state) {
        "done" -> StatusCompleted
        "picked_up" -> StatusPickedUp
        "in_progress" -> StatusInProgress
        "incomplete", "partial" -> StatusIncomplete
        "cancelled" -> StatusCancelled
        else -> StatusPending
    }
    
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp)
        ) {
            // Header: Cliente y Estado
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    modifier = Modifier.weight(1f)
                ) {
                    // Avatar con inicial
                    Surface(
                        shape = CircleShape,
                        color = stateColor.copy(alpha = 0.15f),
                        modifier = Modifier.size(40.dp)
                    ) {
                        Box(contentAlignment = Alignment.Center) {
                            Text(
                                text = line.partnerId.name.firstOrNull()?.uppercase() ?: "?",
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                color = stateColor
                            )
                        }
                    }
                    
                    Column {
                        Text(
                            text = line.partnerId.name,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onSurface,
                            maxLines = 1
                        )
                        if (!line.obra.isNullOrEmpty()) {
                            Text(
                                text = "📍 ${line.obra}",
                                fontSize = 12.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                maxLines = 1
                            )
                        }
                    }
                }
                
                // Badge de estado
                Surface(
                    shape = RoundedCornerShape(8.dp),
                    color = stateColor.copy(alpha = 0.15f)
                ) {
                    Text(
                        text = when (line.state) {
                            "done" -> "✓ Entregado"
                            "picked_up" -> "📦 Recogido"
                            "in_progress" -> "🚛 En camino"
                            "incomplete" -> "⚠ Incompleta"
                            "partial" -> "⚠ Parcial"
                            "cancelled" -> "✗ Cancelado"
                            else -> "⏳ Pendiente"
                        },
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Medium,
                        color = stateColor,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }
            }
            
            // Dirección
            if (!line.street.isNullOrEmpty()) {
                Spacer(modifier = Modifier.height(10.dp))
                Row(
                    verticalAlignment = Alignment.Top,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Place,
                        contentDescription = null,
                        modifier = Modifier.size(16.dp),
                        tint = MaterialTheme.colorScheme.primary
                    )
                    Column {
                        Text(
                            text = line.street,
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        if (!line.city.isNullOrEmpty()) {
                            Text(
                                text = line.city,
                                fontSize = 11.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            }
            
            // Notas/Descripción
            if (!line.notes.isNullOrEmpty()) {
                Spacer(modifier = Modifier.height(8.dp))
                Surface(
                    shape = RoundedCornerShape(10.dp),
                    color = MaterialTheme.colorScheme.surface,
                    shadowElevation = 1.dp,
                    tonalElevation = 2.dp
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(12.dp),
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Notes,
                            contentDescription = null,
                            modifier = Modifier.size(18.dp),
                            tint = LogticPrimaryGradientStart
                        )
                        Text(
                            text = parseHtmlToPlainText(line.notes),
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurface,
                            lineHeight = 18.sp
                        )
                    }
                }
            }
            
            // Tiempos
            if (line.startTime != null || line.pickupTime != null || line.endTime != null) {
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    if (line.startTime != null) {
                        TimeChip(
                            icon = Icons.Default.PlayArrow,
                            time = formatDateTime(line.startTime),
                            color = StatusInProgress
                        )
                    }
                    if (line.pickupTime != null) {
                        TimeChip(
                            icon = Icons.Default.LocalShipping,
                            time = formatDateTime(line.pickupTime),
                            color = StatusPickedUp
                        )
                    }
                    if (line.endTime != null) {
                        TimeChip(
                            icon = Icons.Default.CheckCircle,
                            time = formatDateTime(line.endTime),
                            color = StatusCompleted
                        )
                    }
                }
            }
            
            // Productos (si tiene)
            if (!line.orderLines.isNullOrEmpty()) {
                var showProducts by remember { mutableStateOf(false) }
                
                Spacer(modifier = Modifier.height(10.dp))
                
                Surface(
                    onClick = { showProducts = !showProducts },
                    shape = RoundedCornerShape(10.dp),
                    color = MaterialTheme.colorScheme.primaryContainer.copy(alpha = 0.5f)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(10.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = Icons.Default.Inventory,
                                contentDescription = null,
                                modifier = Modifier.size(18.dp),
                                tint = MaterialTheme.colorScheme.primary
                            )
                            Text(
                                text = "${line.orderLines.size} productos",
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Medium,
                                color = MaterialTheme.colorScheme.primary
                            )
                            if (!line.orderName.isNullOrEmpty()) {
                                Text(
                                    text = "• ${line.orderName}",
                                    fontSize = 11.sp,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }
                        Icon(
                            imageVector = if (showProducts) Icons.Default.ExpandLess else Icons.Default.ExpandMore,
                            contentDescription = null,
                            modifier = Modifier.size(20.dp),
                            tint = MaterialTheme.colorScheme.primary
                        )
                    }
                }
                
                AnimatedVisibility(
                    visible = showProducts,
                    enter = expandVertically(
                        animationSpec = spring(
                            dampingRatio = Spring.DampingRatioLowBouncy,
                            stiffness = Spring.StiffnessLow
                        )
                    ) + fadeIn(),
                    exit = shrinkVertically(
                        animationSpec = spring(
                            dampingRatio = Spring.DampingRatioNoBouncy,
                            stiffness = Spring.StiffnessMedium
                        )
                    ) + fadeOut()
                ) {
                    Column(
                        modifier = Modifier.padding(top = 8.dp),
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        line.orderLines.forEach { orderLine ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(horizontal = 8.dp, vertical = 4.dp),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text(
                                    text = orderLine.productName,
                                    fontSize = 12.sp,
                                    color = MaterialTheme.colorScheme.onSurface,
                                    modifier = Modifier.weight(1f)
                                )
                                Text(
                                    text = "${orderLine.quantity.toInt()} ${orderLine.uom}",
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Medium,
                                    color = MaterialTheme.colorScheme.primary
                                )
                            }
                        }
                    }
                }
            }
            
            // ============ ARCHIVOS ADJUNTOS ============
            if (!line.attachments.isNullOrEmpty()) {
                AttachmentsSection(
                    attachments = line.attachments,
                    odooViewModel = odooViewModel,
                    context = context
                )
            }
            
            // ============ MOTIVO DE INCOMPLETA/PARCIAL ============
            if (line.state in listOf("incomplete", "partial") && 
                (!line.incompleteReason.isNullOrEmpty() || !line.incompleteNotes.isNullOrEmpty())) {
                Spacer(modifier = Modifier.height(8.dp))
                Surface(
                    shape = RoundedCornerShape(10.dp),
                    color = StatusIncomplete.copy(alpha = 0.10f)
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(10.dp)
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = Icons.Default.Warning,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp),
                                tint = StatusIncomplete
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = "Motivo: ${getReasonLabel(line.incompleteReason ?: "")}",
                                fontSize = 12.sp,
                                fontWeight = FontWeight.SemiBold,
                                color = StatusIncomplete
                            )
                        }
                        if (!line.incompleteNotes.isNullOrEmpty()) {
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = line.incompleteNotes,
                                fontSize = 11.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(12.dp))
            
            // Botones de acción
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // Botón Maps
                Button(
                    onClick = {
                        val destination = if (!line.street.isNullOrEmpty()) {
                            URLEncoder.encode(line.street, "UTF-8")
                        } else {
                            val lat = line.latitude ?: 0.0
                            val lng = line.longitude ?: 0.0
                            "$lat,$lng"
                        }
                        
                        val navigationUri = Uri.parse("google.navigation:q=$destination&mode=d")
                        val mapIntent = Intent(Intent.ACTION_VIEW, navigationUri)
                        mapIntent.setPackage("com.google.android.apps.maps")
                        
                        if (mapIntent.resolveActivity(context.packageManager) != null) {
                            context.startActivity(mapIntent)
                        } else {
                            val browserIntent = Intent(
                                Intent.ACTION_VIEW,
                                Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving")
                            )
                            context.startActivity(browserIntent)
                        }
                    },
                    modifier = Modifier.weight(1f),
                    shape = RoundedCornerShape(12.dp),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = LogticBlue
                    ),
                    enabled = line.state !in listOf("done", "cancelled", "incomplete", "partial"),
                    contentPadding = PaddingValues(vertical = 12.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Navigation,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(text = "Navegar", fontSize = 13.sp)
                }
                
                // Botones de estado según el estado actual
                when (line.state) {
                    "pending" -> {
                        OutlinedButton(
                            onClick = {
                                if (ContextCompat.checkSelfPermission(
                                        context,
                                        Manifest.permission.ACCESS_FINE_LOCATION
                                    ) == PackageManager.PERMISSION_GRANTED
                                ) {
                                    fusedLocationClient.lastLocation.addOnSuccessListener { location ->
                                        odooViewModel.notifyLineStarted(
                                            line.id,
                                            location?.latitude,
                                            location?.longitude
                                        )
                                    }
                                } else {
                                    odooViewModel.notifyLineStarted(line.id)
                                }
                            },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            contentPadding = PaddingValues(vertical = 12.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.PlayArrow,
                                contentDescription = null,
                                modifier = Modifier.size(18.dp)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(text = "Iniciar", fontSize = 13.sp)
                        }
                    }
                    "in_progress" -> {
                        // Botón Recoger
                        Button(
                            onClick = {
                                if (ContextCompat.checkSelfPermission(
                                        context,
                                        Manifest.permission.ACCESS_FINE_LOCATION
                                    ) == PackageManager.PERMISSION_GRANTED
                                ) {
                                    fusedLocationClient.lastLocation.addOnSuccessListener { location ->
                                        odooViewModel.notifyLinePickedUp(
                                            line.id,
                                            location?.latitude,
                                            location?.longitude
                                        )
                                    }
                                } else {
                                    odooViewModel.notifyLinePickedUp(line.id)
                                }
                            },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = StatusPickedUp
                            ),
                            contentPadding = PaddingValues(vertical = 12.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.LocalShipping,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(text = "Recoger", fontSize = 11.sp)
                        }
                        
                        // Botón Finalizar con foto
                        Button(
                            onClick = { showPhotoDialog = true },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = StatusCompleted
                            ),
                            contentPadding = PaddingValues(vertical = 12.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.CameraAlt,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(text = "Finalizar", fontSize = 11.sp)
                        }
                        
                        // Botón Incompleta
                        OutlinedButton(
                            onClick = { showIncompleteDialog = true },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            colors = ButtonDefaults.outlinedButtonColors(
                                contentColor = StatusIncomplete
                            ),
                            contentPadding = PaddingValues(vertical = 12.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Warning,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(text = "Incompleta", fontSize = 11.sp)
                        }
                    }
                    "picked_up" -> {
                        // Botón Finalizar con foto
                        Button(
                            onClick = { showPhotoDialog = true },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = StatusCompleted
                            ),
                            contentPadding = PaddingValues(vertical = 12.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.CameraAlt,
                                contentDescription = null,
                                modifier = Modifier.size(18.dp)
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(text = "Finalizar con Foto", fontSize = 12.sp)
                        }
                        
                        // Botón Incompleta
                        OutlinedButton(
                            onClick = { showIncompleteDialog = true },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            colors = ButtonDefaults.outlinedButtonColors(
                                contentColor = StatusIncomplete
                            ),
                            contentPadding = PaddingValues(vertical = 12.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Warning,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(text = "Incompleta", fontSize = 12.sp)
                        }
                    }
                    "done" -> {
                        Surface(
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            color = StatusCompleted.copy(alpha = 0.15f)
                        ) {
                            Row(
                                modifier = Modifier.padding(vertical = 12.dp),
                                horizontalArrangement = Arrangement.Center,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.CheckCircle,
                                    contentDescription = null,
                                    modifier = Modifier.size(18.dp),
                                    tint = StatusCompleted
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "Completada",
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Medium,
                                    color = StatusCompleted
                                )
                            }
                        }
                    }
                    "incomplete", "partial" -> {
                        Surface(
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            color = StatusIncomplete.copy(alpha = 0.15f)
                        ) {
                            Row(
                                modifier = Modifier.padding(vertical = 12.dp),
                                horizontalArrangement = Arrangement.Center,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Warning,
                                    contentDescription = null,
                                    modifier = Modifier.size(18.dp),
                                    tint = StatusIncomplete
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = if (line.state == "incomplete") "Incompleta" else "Parcial",
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Medium,
                                    color = StatusIncomplete
                                )
                            }
                        }
                    }
                    else -> {
                        Surface(
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            color = StatusCancelled.copy(alpha = 0.15f)
                        ) {
                            Row(
                                modifier = Modifier.padding(vertical = 12.dp),
                                horizontalArrangement = Arrangement.Center,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = "Cancelada",
                                    fontSize = 13.sp,
                                    color = StatusCancelled
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Dialog para capturar foto
    if (showPhotoDialog) {
        PhotoCaptureDialog(
            partnerName = line.partnerId.name,
            onDismiss = { 
                showPhotoDialog = false
                odooViewModel.clearUploadState()
            },
            onPhotoSelected = { imageBase64, notes ->
                odooViewModel.completeLineWithImage(
                    lineId = line.id,
                    imageBase64 = imageBase64,
                    latitude = currentLocation.first,
                    longitude = currentLocation.second,
                    notes = notes,
                    onComplete = { success ->
                        if (success) {
                            showPhotoDialog = false
                        }
                    }
                )
            },
            isUploading = odooViewModel.isUploadingImage.value
        )
    }
    
    // Dialog para marcar como incompleta/parcial
    if (showIncompleteDialog) {
        IncompleteReasonDialog(
            partnerName = line.partnerId.name,
            onDismiss = { showIncompleteDialog = false },
            onConfirm = { state, reason, notes ->
                if (ContextCompat.checkSelfPermission(
                        context,
                        Manifest.permission.ACCESS_FINE_LOCATION
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    fusedLocationClient.lastLocation.addOnSuccessListener { location ->
                        odooViewModel.notifyLineIncomplete(
                            lineId = line.id,
                            incompleteState = state,
                            reason = reason,
                            notes = notes,
                            latitude = location?.latitude,
                            longitude = location?.longitude
                        )
                    }
                } else {
                    odooViewModel.notifyLineIncomplete(
                        lineId = line.id,
                        incompleteState = state,
                        reason = reason,
                        notes = notes
                    )
                }
                showIncompleteDialog = false
            }
        )
    }
}

// Helper para traducir el código de motivo a texto legible
fun getReasonLabel(reason: String): String {
    return when (reason) {
        "no_material" -> "Proveedor sin material"
        "not_needed" -> "Ya no se necesita"
        "order_error" -> "Error en la orden"
        "wrong_address" -> "Dirección incorrecta"
        "closed" -> "Establecimiento cerrado"
        "no_access" -> "Sin acceso al lugar"
        "damaged" -> "Material dañado"
        "other" -> "Otro motivo"
        else -> reason
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun IncompleteReasonDialog(
    partnerName: String,
    onDismiss: () -> Unit,
    onConfirm: (state: String, reason: String, notes: String) -> Unit
) {
    val reasonOptions = listOf(
        "no_material" to "Proveedor sin material",
        "not_needed" to "Ya no se necesita",
        "order_error" to "Error en la orden",
        "wrong_address" to "Dirección incorrecta",
        "closed" to "Establecimiento cerrado",
        "no_access" to "Sin acceso al lugar",
        "damaged" to "Material dañado",
        "other" to "Otro motivo"
    )
    
    var selectedState by remember { mutableStateOf("incomplete") }
    var selectedReason by remember { mutableStateOf("") }
    var notes by remember { mutableStateOf("") }
    var reasonExpanded by remember { mutableStateOf(false) }
    
    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Column {
                Text(
                    text = "Marcar como incompleta",
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp
                )
                Text(
                    text = partnerName,
                    fontSize = 13.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        },
        text = {
            Column(
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Selector de tipo: Incompleta o Parcial
                Text(
                    text = "Tipo",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium
                )
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    FilterChip(
                        selected = selectedState == "incomplete",
                        onClick = { selectedState = "incomplete" },
                        label = { Text("Incompleta", fontSize = 12.sp) },
                        leadingIcon = if (selectedState == "incomplete") {
                            { Icon(Icons.Default.Check, contentDescription = null, modifier = Modifier.size(16.dp)) }
                        } else null
                    )
                    FilterChip(
                        selected = selectedState == "partial",
                        onClick = { selectedState = "partial" },
                        label = { Text("Parcial", fontSize = 12.sp) },
                        leadingIcon = if (selectedState == "partial") {
                            { Icon(Icons.Default.Check, contentDescription = null, modifier = Modifier.size(16.dp)) }
                        } else null
                    )
                }
                
                // Dropdown de motivo
                Text(
                    text = "Motivo",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium
                )
                ExposedDropdownMenuBox(
                    expanded = reasonExpanded,
                    onExpandedChange = { reasonExpanded = it }
                ) {
                    OutlinedTextField(
                        value = reasonOptions.find { it.first == selectedReason }?.second ?: "",
                        onValueChange = {},
                        readOnly = true,
                        placeholder = { Text("Seleccione un motivo", fontSize = 13.sp) },
                        trailingIcon = {
                            ExposedDropdownMenuDefaults.TrailingIcon(expanded = reasonExpanded)
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .menuAnchor(),
                        textStyle = androidx.compose.ui.text.TextStyle(fontSize = 13.sp)
                    )
                    ExposedDropdownMenu(
                        expanded = reasonExpanded,
                        onDismissRequest = { reasonExpanded = false }
                    ) {
                        reasonOptions.forEach { (key, label) ->
                            DropdownMenuItem(
                                text = { Text(label, fontSize = 13.sp) },
                                onClick = {
                                    selectedReason = key
                                    reasonExpanded = false
                                }
                            )
                        }
                    }
                }
                
                // Campo de notas
                Text(
                    text = "Detalle adicional (opcional)",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium
                )
                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    placeholder = { Text("Explique el motivo...", fontSize = 13.sp) },
                    modifier = Modifier.fillMaxWidth(),
                    minLines = 2,
                    maxLines = 4,
                    textStyle = androidx.compose.ui.text.TextStyle(fontSize = 13.sp)
                )
            }
        },
        confirmButton = {
            Button(
                onClick = { onConfirm(selectedState, selectedReason, notes) },
                enabled = selectedReason.isNotEmpty(),
                colors = ButtonDefaults.buttonColors(
                    containerColor = StatusIncomplete
                )
            ) {
                Text("Confirmar")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancelar")
            }
        }
    )
}

@Composable
fun TimeChip(
    icon: ImageVector,
    time: String,
    color: androidx.compose.ui.graphics.Color
) {
    Surface(
        shape = RoundedCornerShape(6.dp),
        color = color.copy(alpha = 0.1f)
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(12.dp),
                tint = color
            )
            Text(
                text = time,
                fontSize = 10.sp,
                color = color
            )
        }
    }
}

// Mantener compatibilidad - componentes legacy ya no usados
@Composable
fun ExpandableRouteHeader(
    routeName: String,
    routeLines: List<com.example.logtic.data.api.RouteLineData>,
    odooViewModel: OdooViewModel,
    context: android.content.Context
) {
    // Redirigir al nuevo componente
    ModernExpandableRouteCard(
        routeName = routeName,
        routeLines = routeLines,
        routeData = odooViewModel.odooRoutes.value.find { it.name == routeName },
        odooViewModel = odooViewModel,
        context = context
    )
}

@Composable
fun RouteActivityCard(
    line: com.example.logtic.data.api.RouteLineData,
    odooViewModel: OdooViewModel,
    context: android.content.Context
) {
    // Redirigir al nuevo componente
    ModernRouteActivityCard(
        line = line,
        odooViewModel = odooViewModel,
        context = context
    )
}

// ============ SECCIÓN DE ARCHIVOS ADJUNTOS ============

@Composable
fun AttachmentsSection(
    attachments: List<AttachmentData>,
    odooViewModel: OdooViewModel,
    context: android.content.Context
) {
    var showAttachments by remember { mutableStateOf(false) }
    var downloadingId by remember { mutableStateOf<Int?>(null) }
    
    // Animación del icono
    val iconRotation by animateFloatAsState(
        targetValue = if (showAttachments) 180f else 0f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium
        ),
        label = "attachmentIconRotation"
    )
    
    Spacer(modifier = Modifier.height(10.dp))
    
    Surface(
        onClick = { showAttachments = !showAttachments },
        shape = RoundedCornerShape(10.dp),
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 2.dp,
        tonalElevation = 3.dp
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Surface(
                    shape = CircleShape,
                    color = LogticAccent.copy(alpha = 0.15f),
                    modifier = Modifier.size(32.dp)
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(
                            imageVector = Icons.Default.AttachFile,
                            contentDescription = null,
                            modifier = Modifier.size(18.dp),
                            tint = LogticAccent
                        )
                    }
                }
                Column {
                    Text(
                        text = "${attachments.size} archivo${if (attachments.size != 1) "s" else ""} adjunto${if (attachments.size != 1) "s" else ""}",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = "Toca para ver",
                        fontSize = 11.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            Surface(
                shape = CircleShape,
                color = MaterialTheme.colorScheme.surfaceVariant,
                modifier = Modifier.size(28.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = Icons.Default.ExpandMore,
                        contentDescription = null,
                        modifier = Modifier
                            .size(20.dp)
                            .graphicsLayer { rotationZ = iconRotation },
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }
    
    AnimatedVisibility(
        visible = showAttachments,
        enter = expandVertically(
            animationSpec = spring(
                dampingRatio = Spring.DampingRatioLowBouncy,
                stiffness = Spring.StiffnessLow
            )
        ) + fadeIn(),
        exit = shrinkVertically(
            animationSpec = spring(
                dampingRatio = Spring.DampingRatioNoBouncy,
                stiffness = Spring.StiffnessMedium
            )
        ) + fadeOut()
    ) {
        Column(
            modifier = Modifier.padding(top = 8.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            attachments.forEachIndexed { index, attachment ->
                // Animación de entrada escalonada
                val itemAlpha by animateFloatAsState(
                    targetValue = if (showAttachments) 1f else 0f,
                    animationSpec = tween(
                        durationMillis = 200,
                        delayMillis = index * 50
                    ),
                    label = "attachmentAlpha$index"
                )
                
                AttachmentItem(
                    attachment = attachment,
                    isDownloading = downloadingId == attachment.id,
                    modifier = Modifier.graphicsLayer { alpha = itemAlpha },
                    onDownload = {
                        downloadingId = attachment.id
                        odooViewModel.downloadAttachment(
                            attachmentId = attachment.id,
                            onSuccess = { base64Data, filename, mimetype ->
                                downloadingId = null
                                // Guardar y abrir el archivo
                                saveAndOpenFile(context, base64Data, filename, mimetype)
                            },
                            onError = { error ->
                                downloadingId = null
                                Toast.makeText(context, "Error: $error", Toast.LENGTH_SHORT).show()
                            }
                        )
                    }
                )
            }
        }
    }
}

@Composable
fun AttachmentItem(
    attachment: AttachmentData,
    isDownloading: Boolean,
    modifier: Modifier = Modifier,
    onDownload: () -> Unit
) {
    // Animación de pulso cuando está descargando
    val pulseAnimation by rememberInfiniteTransition(label = "pulse").animateFloat(
        initialValue = 1f,
        targetValue = 1.05f,
        animationSpec = infiniteRepeatable(
            animation = tween(500, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "pulseScale"
    )
    
    Surface(
        onClick = { if (!isDownloading) onDownload() },
        shape = RoundedCornerShape(8.dp),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.7f),
        modifier = modifier.scale(if (isDownloading) pulseAnimation else 1f)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(10.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Icono según tipo de archivo
            Surface(
                shape = RoundedCornerShape(6.dp),
                color = getFileIconColor(attachment).copy(alpha = 0.15f),
                modifier = Modifier.size(36.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    if (isDownloading) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(18.dp),
                            strokeWidth = 2.dp,
                            color = getFileIconColor(attachment)
                        )
                    } else {
                        Icon(
                            imageVector = getFileIcon(attachment),
                            contentDescription = null,
                            modifier = Modifier.size(20.dp),
                            tint = getFileIconColor(attachment)
                        )
                    }
                }
            }
            
            // Nombre y detalles del archivo
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = attachment.name,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium,
                    color = MaterialTheme.colorScheme.onSurface,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = attachment.getExtension(),
                        fontSize = 10.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    if (attachment.fileSize != null && attachment.fileSize > 0) {
                        Text(
                            text = "•",
                            fontSize = 10.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Text(
                            text = attachment.formattedFileSize(),
                            fontSize = 10.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
            
            // Botón de descarga
            Surface(
                onClick = { if (!isDownloading) onDownload() },
                shape = CircleShape,
                color = MaterialTheme.colorScheme.primary.copy(alpha = 0.1f),
                modifier = Modifier.size(32.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = if (isDownloading) Icons.Default.HourglassTop else Icons.Default.Download,
                        contentDescription = "Descargar",
                        modifier = Modifier.size(16.dp),
                        tint = MaterialTheme.colorScheme.primary
                    )
                }
            }
        }
    }
}

// Helper para obtener el icono según el tipo de archivo
@Composable
fun getFileIcon(attachment: AttachmentData): ImageVector {
    return when {
        attachment.isImage() -> Icons.Default.Image
        attachment.isPdf() -> Icons.Default.PictureAsPdf
        attachment.mimetype?.contains("spreadsheet") == true || 
        attachment.mimetype?.contains("excel") == true -> Icons.Default.TableChart
        attachment.mimetype?.contains("word") == true || 
        attachment.mimetype?.contains("document") == true -> Icons.Default.Description
        attachment.mimetype?.startsWith("text/") == true -> Icons.Default.TextSnippet
        else -> Icons.Default.InsertDriveFile
    }
}

// Helper para obtener el color del icono según el tipo de archivo
@Composable
fun getFileIconColor(attachment: AttachmentData): androidx.compose.ui.graphics.Color {
    return when {
        attachment.isImage() -> MaterialTheme.colorScheme.tertiary
        attachment.isPdf() -> StatusCancelled // Rojo para PDFs
        attachment.mimetype?.contains("spreadsheet") == true || 
        attachment.mimetype?.contains("excel") == true -> StatusCompleted // Verde para Excel
        attachment.mimetype?.contains("word") == true || 
        attachment.mimetype?.contains("document") == true -> LogticBlue // Azul para Word
        else -> MaterialTheme.colorScheme.secondary
    }
}

// Helper para parsear HTML a texto plano
fun parseHtmlToPlainText(html: String): String {
    return try {
        Html.fromHtml(html, Html.FROM_HTML_MODE_LEGACY).toString().trim()
    } catch (e: Exception) {
        // Si falla el parseo, limpiar manualmente las etiquetas más comunes
        html
            .replace(Regex("<[^>]*>"), "")
            .replace("&nbsp;", " ")
            .replace("&amp;", "&")
            .replace("&lt;", "<")
            .replace("&gt;", ">")
            .replace("&quot;", "\"")
            .trim()
    }
}

// Helper para guardar y abrir el archivo descargado
fun saveAndOpenFile(context: android.content.Context, base64Data: String, filename: String, mimetype: String) {
    try {
        // Decodificar el base64
        val bytes = Base64.decode(base64Data, Base64.DEFAULT)
        
        // Crear archivo temporal
        val cacheDir = File(context.cacheDir, "attachments")
        if (!cacheDir.exists()) cacheDir.mkdirs()
        
        val file = File(cacheDir, filename)
        FileOutputStream(file).use { output ->
            output.write(bytes)
        }
        
        // Crear URI con FileProvider
        val uri = FileProvider.getUriForFile(
            context,
            "${context.packageName}.fileprovider",
            file
        )
        
        // Abrir con la app correspondiente - usar try-catch en lugar de resolveActivity
        // (resolveActivity no funciona correctamente en Android 11+ debido a restricciones de visibilidad de paquetes)
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, mimetype)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        
        try {
            context.startActivity(intent)
        } catch (e: ActivityNotFoundException) {
            // Intentar con un chooser como alternativa
            val chooser = Intent.createChooser(intent, "Abrir con...")
            chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            try {
                context.startActivity(chooser)
            } catch (e2: Exception) {
                Toast.makeText(
                    context, 
                    "No hay app disponible para abrir este archivo ($mimetype)", 
                    Toast.LENGTH_LONG
                ).show()
            }
        }
    } catch (e: Exception) {
        Toast.makeText(context, "Error al abrir archivo: ${e.message}", Toast.LENGTH_SHORT).show()
    }
}
