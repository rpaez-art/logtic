package com.example.logtic.ui.screens

import android.graphics.BitmapFactory
import android.util.Base64
import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.logtic.data.api.DriverStatsData
import com.example.logtic.data.api.RouteHistoryItem
import com.example.logtic.ui.theme.*
import com.example.logtic.viewmodel.AuthViewModel
import com.example.logtic.viewmodel.LocalStats
import com.example.logtic.viewmodel.OdooViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    authViewModel: AuthViewModel,
    odooViewModel: OdooViewModel,
    onNavigateToRoutes: () -> Unit,
    onLogout: () -> Unit,
    onManageUsers: () -> Unit = {},
    onMonitorDrivers: () -> Unit = {},
    onViewHistory: () -> Unit = {}
) {
    val currentUser = authViewModel.currentUser.value
    val isAdmin = currentUser?.username == "admin"
    val driverStats by odooViewModel.driverStats
    val isLoadingStats by odooViewModel.isLoadingStats
    val routesHistory by odooViewModel.routesHistory
    val isLoadingHistory by odooViewModel.isLoadingHistory
    
    var selectedPeriod by remember { mutableStateOf("today") }
    
    // Cargar estadísticas y rutas al iniciar
    LaunchedEffect(currentUser?.driverId, selectedPeriod) {
        currentUser?.driverId?.let { driverId ->
            // Sincronizar rutas primero para tener datos locales
            odooViewModel.syncRoutesFromOdoo(driverId) { _ -> }
            // Luego obtener estadísticas del servidor
            odooViewModel.fetchDriverStats(driverId, selectedPeriod)
            odooViewModel.fetchRoutesHistory(driverId)
        }
    }
    
    // Recalcular localStats cuando cambien las rutas o el historial
    val routes by odooViewModel.odooRoutes
    val history = routesHistory  // Ya está declarado arriba
    val localStats = remember(routes, history) { odooViewModel.getLocalStats() }
    
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                brush = Brush.verticalGradient(
                    colors = listOf(
                        LogticGray100,
                        LogticWhite
                    )
                )
            )
    ) {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(bottom = 100.dp)
        ) {
            // Header con gradiente y foto de perfil
            item {
                DashboardHeader(
                    userName = currentUser?.fullName ?: currentUser?.username ?: "Conductor",
                    driverImage = driverStats?.driver?.image,
                    onLogout = onLogout
                )
            }
            
            // Selector de período
            item {
                PeriodSelector(
                    selectedPeriod = selectedPeriod,
                    onPeriodSelected = { selectedPeriod = it }
                )
            }
            
            // Tarjetas de resumen
            item {
                if (isLoadingStats) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(200.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = LogticPrimary)
                    }
                } else {
                    SummaryCards(
                        stats = driverStats,
                        localStats = localStats
                    )
                }
            }
            
            // Tarjeta de rendimiento
            item {
                PerformanceCard(stats = driverStats, localStats = localStats)
            }
            
            // Progreso de hoy
            item {
                TodayProgressCard(
                    stats = driverStats,
                    localStats = localStats,
                    onViewRoutes = onNavigateToRoutes
                )
            }
            
            // Historial de rutas
            item {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp, vertical = 12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "📜 Historial Reciente",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                    TextButton(onClick = onViewHistory) {
                        Text(
                            text = "Ver todo",
                            color = CorpGreen,
                            fontWeight = FontWeight.SemiBold
                        )
                        Icon(
                            imageVector = Icons.Default.ChevronRight,
                            contentDescription = null,
                            tint = CorpGreen,
                            modifier = Modifier.size(18.dp)
                        )
                    }
                }
            }
            
            if (isLoadingHistory) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(100.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(color = LogticPrimary)
                    }
                }
            } else if (routesHistory.isEmpty()) {
                item {
                    EmptyHistoryCard()
                }
            } else {
                items(routesHistory.take(5)) { historyItem ->
                    HistoryItemCard(item = historyItem)
                }
            }
        }
        
        // Botón flotante para ir a rutas - MÁS GRANDE para facilitar touch
        FloatingActionButton(
            onClick = onNavigateToRoutes,
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(24.dp)
                .size(80.dp),  // Más grande para facilitar presionar
            containerColor = LogticOrange,  // Dorado corporativo
            contentColor = LogticWhite,
            shape = CircleShape,
            elevation = FloatingActionButtonDefaults.elevation(
                defaultElevation = 12.dp,
                pressedElevation = 16.dp
            )
        ) {
            Icon(
                imageVector = Icons.Default.LocalShipping,
                contentDescription = "Ver Rutas",
                modifier = Modifier.size(40.dp)  // Icono más grande
            )
        }
    }
}

@Composable
fun DashboardHeader(
    userName: String,
    driverImage: String?,
    onLogout: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(220.dp)
    ) {
        // Fondo con gradiente corporativo
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(180.dp)
                .background(
                    brush = Brush.linearGradient(
                        colors = listOf(
                            LogticOrange,      // Dorado corporativo
                            CorpGreen,         // Verde corporativo
                            CorpDarkGray       // Gris oscuro corporativo
                        )
                    ),
                    shape = RoundedCornerShape(bottomStart = 32.dp, bottomEnd = 32.dp)
                )
        )
        
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp)
        ) {
            // Fila superior con saludo y logout
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "¡Hola!",
                        color = LogticWhite.copy(alpha = 0.9f),
                        fontSize = 16.sp
                    )
                    Text(
                        text = userName,
                        color = LogticWhite,
                        fontSize = 24.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
                
                IconButton(
                    onClick = onLogout,
                    modifier = Modifier
                        .background(
                            color = LogticWhite.copy(alpha = 0.2f),
                            shape = CircleShape
                        )
                ) {
                    Icon(
                        imageVector = Icons.Default.Logout,
                        contentDescription = "Cerrar Sesión",
                        tint = LogticWhite
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(20.dp))
            
            // Tarjeta con foto de perfil
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .shadow(12.dp, RoundedCornerShape(20.dp)),
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(containerColor = LogticWhite)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Foto de perfil
                    Box(
                        modifier = Modifier
                            .size(70.dp)
                            .clip(CircleShape)
                            .background(
                                brush = Brush.linearGradient(
                                    colors = listOf(
                                        LogticPrimary,
                                        LogticAccent
                                    )
                                )
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        if (driverImage != null) {
                            val bitmap = remember(driverImage) {
                                try {
                                    val bytes = Base64.decode(driverImage, Base64.DEFAULT)
                                    BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                                } catch (e: Exception) {
                                    null
                                }
                            }
                            
                            if (bitmap != null) {
                                Image(
                                    bitmap = bitmap.asImageBitmap(),
                                    contentDescription = "Foto de perfil",
                                    modifier = Modifier
                                        .fillMaxSize()
                                        .clip(CircleShape),
                                    contentScale = ContentScale.Crop
                                )
                            } else {
                                DefaultProfileIcon()
                            }
                        } else {
                            DefaultProfileIcon()
                        }
                    }
                    
                    Spacer(modifier = Modifier.width(16.dp))
                    
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Conductor Activo",
                            style = MaterialTheme.typography.labelMedium,
                            color = LogticGray500
                        )
                        Text(
                            text = userName,
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold,
                            color = LogticGray900
                        )
                        Row(
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(8.dp)
                                    .background(StatusCompleted, CircleShape)
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = "En servicio",
                                style = MaterialTheme.typography.bodySmall,
                                color = StatusCompleted
                            )
                        }
                    }
                    
                    Icon(
                        imageVector = Icons.Default.ChevronRight,
                        contentDescription = null,
                        tint = LogticGray400
                    )
                }
            }
        }
    }
}

@Composable
fun DefaultProfileIcon() {
    Icon(
        imageVector = Icons.Default.Person,
        contentDescription = "Perfil",
        tint = LogticWhite,
        modifier = Modifier.size(40.dp)
    )
}

@Composable
fun PeriodSelector(
    selectedPeriod: String,
    onPeriodSelected: (String) -> Unit
) {
    val periods = listOf(
        "today" to "Hoy",
        "week" to "Semana",
        "month" to "Mes",
        "all" to "Todo"
    )
    
    LazyRow(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        items(periods) { (value, label) ->
            FilterChip(
                selected = selectedPeriod == value,
                onClick = { onPeriodSelected(value) },
                label = {
                    Text(
                        text = label,
                        fontWeight = if (selectedPeriod == value) FontWeight.Bold else FontWeight.Normal,
                        color = if (selectedPeriod == value) LogticWhite else CorpDarkGray
                    )
                },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = CorpGreen,
                    selectedLabelColor = LogticWhite,
                    containerColor = LogticWhite,
                    labelColor = CorpDarkGray
                ),
                border = FilterChipDefaults.filterChipBorder(
                    borderColor = if (selectedPeriod == value) CorpGreen else CorpDarkGray.copy(alpha = 0.3f),
                    borderWidth = if (selectedPeriod == value) 2.dp else 1.dp,
                    enabled = true,
                    selected = selectedPeriod == value
                )
            )
        }
    }
}

@Composable
fun SummaryCards(
    stats: DriverStatsData?,
    localStats: LocalStats
) {
    val summary = stats?.summary
    
    LazyRow(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        contentPadding = PaddingValues(horizontal = 20.dp)
    ) {
        item {
            MiniStatCard(
                icon = Icons.Outlined.ListAlt,
                value = "${summary?.totalDeliveries ?: localStats.totalDeliveries}",
                label = "Total",
                gradient = listOf(LogticBlue, LogticBlueDark)
            )
        }
        item {
            MiniStatCard(
                icon = Icons.Outlined.CheckCircle,
                value = "${summary?.completedDeliveries ?: localStats.completedDeliveries}",
                label = "Completadas",
                gradient = listOf(StatusCompleted, LogticGreenDark)
            )
        }
        item {
            MiniStatCard(
                icon = Icons.Outlined.LocalShipping,
                value = "${summary?.inProgressDeliveries ?: localStats.inProgressDeliveries}",
                label = "En Curso",
                gradient = listOf(LogticPrimary, LogticOrangeDark)
            )
        }
        item {
            MiniStatCard(
                icon = Icons.Outlined.Schedule,
                value = "${summary?.pendingDeliveries ?: localStats.pendingDeliveries}",
                label = "Pendientes",
                gradient = listOf(LogticGray600, LogticGray800)
            )
        }
    }
}

@Composable
fun MiniStatCard(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    value: String,
    label: String,
    gradient: List<Color>
) {
    Card(
        modifier = Modifier
            .width(140.dp)
            .height(100.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.Transparent)
    ) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    brush = Brush.linearGradient(colors = gradient),
                    shape = RoundedCornerShape(16.dp)
                )
                .padding(12.dp)
        ) {
            Column(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.SpaceBetween
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = LogticWhite.copy(alpha = 0.9f),
                    modifier = Modifier.size(24.dp)
                )
                Column {
                    Text(
                        text = value,
                        color = LogticWhite,
                        fontSize = 28.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = label,
                        color = LogticWhite.copy(alpha = 0.8f),
                        fontSize = 12.sp
                    )
                }
            }
        }
    }
}

@Composable
fun PerformanceCard(stats: DriverStatsData?, localStats: LocalStats) {
    val performance = stats?.performance
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 8.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = LogticWhite),
        elevation = CardDefaults.cardElevation(4.dp)
    ) {
        Column(
            modifier = Modifier.padding(20.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Speed,
                    contentDescription = null,
                    tint = LogticPrimary,
                    modifier = Modifier.size(24.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Rendimiento",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                PerformanceMetric(
                    icon = Icons.Outlined.Timer,
                    value = performance?.avgDeliveryTimeFormatted?.takeIf { it != "0m" && it.isNotEmpty() } 
                        ?: localStats.avgDeliveryTimeFormatted,
                    label = "Prom. Entrega"
                )
                
                VerticalDivider(
                    modifier = Modifier.height(60.dp),
                    color = LogticGray200
                )
                
                PerformanceMetric(
                    icon = Icons.Outlined.Route,
                    value = performance?.avgRouteTimeFormatted?.takeIf { it != "0m" && it.isNotEmpty() }
                        ?: localStats.avgRouteTimeFormatted,
                    label = "Prom. Ruta"
                )
                
                VerticalDivider(
                    modifier = Modifier.height(60.dp),
                    color = LogticGray200
                )
                
                PerformanceMetric(
                    icon = Icons.Outlined.TrendingUp,
                    value = "${stats?.summary?.completionRate?.toInt() ?: localStats.completionRate.toInt()}%",
                    label = "Eficiencia"
                )
            }
        }
    }
}

@Composable
fun PerformanceMetric(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    value: String,
    label: String
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = CorpGreen,
            modifier = Modifier.size(28.dp)
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = value,
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            color = CorpDarkGray
        )
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = CorpDarkGray.copy(alpha = 0.7f)
        )
    }
}

@Composable
fun TodayProgressCard(
    stats: DriverStatsData?,
    localStats: LocalStats,
    onViewRoutes: () -> Unit
) {
    val today = stats?.today
    val completed = today?.completed ?: localStats.completedDeliveries
    val total = today?.total ?: localStats.totalDeliveries
    val progress = if (total > 0) completed.toFloat() / total.toFloat() else 0f
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 8.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = LogticWhite),
        elevation = CardDefaults.cardElevation(4.dp)
    ) {
        Column(
            modifier = Modifier.padding(20.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Today,
                        contentDescription = null,
                        tint = LogticPrimary,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Progreso de Hoy",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                }
                
                TextButton(onClick = onViewRoutes) {
                    Text("Ver rutas", color = LogticPrimary)
                    Icon(
                        imageVector = Icons.Default.ArrowForward,
                        contentDescription = null,
                        tint = LogticPrimary,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Barra de progreso circular grande
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Progreso circular
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier.size(120.dp)
                ) {
                    CircularProgressIndicator(
                        progress = { 1f },
                        modifier = Modifier.fillMaxSize(),
                        strokeWidth = 12.dp,
                        color = LogticGray200,
                    )
                    CircularProgressIndicator(
                        progress = { progress },
                        modifier = Modifier.fillMaxSize(),
                        strokeWidth = 12.dp,
                        color = LogticPrimary,
                    )
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "${(progress * 100).toInt()}%",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                            color = LogticPrimary
                        )
                        Text(
                            text = "$completed de $total",
                            style = MaterialTheme.typography.bodySmall,
                            color = LogticGray500
                        )
                    }
                }
                
                // Detalle
                Column {
                    TodayStatItem(
                        color = StatusCompleted,
                        label = "Completadas",
                        value = completed
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    TodayStatItem(
                        color = StatusInProgress,
                        label = "En curso",
                        value = today?.inProgress ?: localStats.inProgressDeliveries
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    TodayStatItem(
                        color = StatusPending,
                        label = "Pendientes",
                        value = today?.pending ?: localStats.pendingDeliveries
                    )
                }
            }
        }
    }
}

@Composable
fun TodayStatItem(
    color: Color,
    label: String,
    value: Int
) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
            modifier = Modifier
                .size(12.dp)
                .background(color, CircleShape)
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = "$value $label",
            style = MaterialTheme.typography.bodyMedium,
            color = LogticGray700
        )
    }
}

@Composable
fun HistoryItemCard(item: RouteHistoryItem) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 4.dp),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = LogticWhite),
        elevation = CardDefaults.cardElevation(2.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Icono con fondo
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .background(
                        color = StatusCompleted.copy(alpha = 0.1f),
                        shape = RoundedCornerShape(12.dp)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.CheckCircle,
                    contentDescription = null,
                    tint = StatusCompleted,
                    modifier = Modifier.size(24.dp)
                )
            }
            
            Spacer(modifier = Modifier.width(12.dp))
            
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = item.name,
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.SemiBold,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = item.date,
                    style = MaterialTheme.typography.bodySmall,
                    color = LogticGray500
                )
            }
            
            Column(horizontalAlignment = Alignment.End) {
                Text(
                    text = item.durationFormatted,
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Bold,
                    color = LogticPrimary
                )
                Text(
                    text = "${item.completedDeliveries}/${item.totalDeliveries} entregas",
                    style = MaterialTheme.typography.bodySmall,
                    color = LogticGray500
                )
            }
        }
    }
}

@Composable
fun EmptyHistoryCard() {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp, vertical = 8.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = LogticGray50)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = Icons.Outlined.History,
                contentDescription = null,
                tint = LogticGray400,
                modifier = Modifier.size(48.dp)
            )
            Spacer(modifier = Modifier.height(12.dp))
            Text(
                text = "Sin historial aún",
                style = MaterialTheme.typography.titleSmall,
                color = LogticGray600
            )
            Text(
                text = "Completa tus primeras rutas para ver tu historial aquí",
                style = MaterialTheme.typography.bodySmall,
                color = LogticGray500,
                textAlign = TextAlign.Center
            )
        }
    }
}
