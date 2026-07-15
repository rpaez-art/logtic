package com.example.logtic.ui.screens

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.logtic.data.api.RouteHistoryItem
import com.example.logtic.ui.theme.*
import com.example.logtic.viewmodel.AuthViewModel
import com.example.logtic.viewmodel.OdooViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RouteHistoryScreen(
    authViewModel: AuthViewModel,
    odooViewModel: OdooViewModel,
    onBack: () -> Unit
) {
    val currentUser = authViewModel.currentUser.value
    val routesHistory by odooViewModel.routesHistory
    val isLoadingHistory by odooViewModel.isLoadingHistory
    var hasLoadedMore by remember { mutableStateOf(false) }
    
    // Cargar historial completo al entrar
    LaunchedEffect(currentUser?.driverId) {
        currentUser?.driverId?.let { driverId ->
            odooViewModel.fetchRoutesHistory(driverId, limit = 50)
        }
    }
    
    // Calcular resumen del historial
    val totalRoutes = routesHistory.size
    val totalDeliveries = routesHistory.sumOf { it.totalDeliveries }
    val totalCompleted = routesHistory.sumOf { it.completedDeliveries }
    val avgDuration = if (routesHistory.isNotEmpty()) {
        routesHistory.filter { it.durationMinutes > 0 }
            .let { withDuration ->
                if (withDuration.isNotEmpty()) withDuration.sumOf { it.durationMinutes } / withDuration.size
                else 0.0
            }
    } else 0.0
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        "Historial de Rutas",
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Volver")
                    }
                },
                actions = {
                    IconButton(
                        onClick = {
                            currentUser?.driverId?.let { driverId ->
                                odooViewModel.fetchRoutesHistory(driverId, limit = 50)
                            }
                        }
                    ) {
                        Icon(Icons.Default.Refresh, contentDescription = "Actualizar")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = CorpGreen,
                    titleContentColor = LogticWhite,
                    navigationIconContentColor = LogticWhite,
                    actionIconContentColor = LogticWhite
                )
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .background(
                    brush = Brush.verticalGradient(
                        colors = listOf(LogticGray100, LogticWhite)
                    )
                ),
            contentPadding = PaddingValues(bottom = 24.dp)
        ) {
            // Resumen superior
            item {
                HistorySummarySection(
                    totalRoutes = totalRoutes,
                    totalDeliveries = totalDeliveries,
                    totalCompleted = totalCompleted,
                    avgDurationMinutes = avgDuration
                )
            }
            
            // Estado de carga
            if (isLoadingHistory) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(200.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            CircularProgressIndicator(color = CorpGreen)
                            Spacer(modifier = Modifier.height(12.dp))
                            Text(
                                "Cargando historial...",
                                color = LogticGray500,
                                style = MaterialTheme.typography.bodyMedium
                            )
                        }
                    }
                }
            } else if (routesHistory.isEmpty()) {
                item {
                    EmptyHistorySection()
                }
            } else {
                // Título de la lista
                item {
                    Text(
                        text = "Rutas Completadas",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 20.dp, vertical = 12.dp)
                    )
                }
                
                // Lista de rutas
                items(routesHistory) { historyItem ->
                    HistoryDetailCard(item = historyItem)
                }
                
                // Botón cargar más
                if (routesHistory.size >= 50 && !hasLoadedMore) {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(20.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            OutlinedButton(
                                onClick = {
                                    currentUser?.driverId?.let { driverId ->
                                        odooViewModel.fetchRoutesHistory(
                                            driverId,
                                            limit = 100,
                                            offset = routesHistory.size
                                        )
                                        hasLoadedMore = true
                                    }
                                },
                                colors = ButtonDefaults.outlinedButtonColors(contentColor = CorpGreen)
                            ) {
                                Icon(Icons.Default.ExpandMore, contentDescription = null)
                                Spacer(modifier = Modifier.width(8.dp))
                                Text("Cargar más rutas")
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun HistorySummarySection(
    totalRoutes: Int,
    totalDeliveries: Int,
    totalCompleted: Int,
    avgDurationMinutes: Double
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.Transparent),
        elevation = CardDefaults.cardElevation(0.dp)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    brush = Brush.linearGradient(
                        colors = listOf(CorpGreen, LogticPrimaryLight)
                    ),
                    shape = RoundedCornerShape(20.dp)
                )
                .padding(20.dp)
        ) {
            Column {
                Text(
                    text = "Resumen General",
                    color = LogticWhite,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
                
                Spacer(modifier = Modifier.height(16.dp))
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    HistoryStat(
                        value = "$totalRoutes",
                        label = "Rutas",
                        icon = Icons.Outlined.Route
                    )
                    HistoryStat(
                        value = "$totalDeliveries",
                        label = "Entregas",
                        icon = Icons.Outlined.LocalShipping
                    )
                    HistoryStat(
                        value = "$totalCompleted",
                        label = "Completadas",
                        icon = Icons.Outlined.CheckCircle
                    )
                    HistoryStat(
                        value = formatDuration(avgDurationMinutes),
                        label = "Prom. Duración",
                        icon = Icons.Outlined.Timer
                    )
                }
            }
        }
    }
}

@Composable
private fun HistoryStat(
    value: String,
    label: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = LogticWhite.copy(alpha = 0.8f),
            modifier = Modifier.size(20.dp)
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = value,
            color = LogticWhite,
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold
        )
        Text(
            text = label,
            color = LogticWhite.copy(alpha = 0.7f),
            fontSize = 10.sp,
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun HistoryDetailCard(item: RouteHistoryItem) {
    val completionRate = if (item.totalDeliveries > 0) {
        (item.completedDeliveries * 100f / item.totalDeliveries)
    } else 0f
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 4.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = LogticWhite),
        elevation = CardDefaults.cardElevation(2.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Icono de estado
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .background(
                            color = if (completionRate >= 100f) StatusCompleted.copy(alpha = 0.1f)
                            else LogticOrange.copy(alpha = 0.1f),
                            shape = RoundedCornerShape(12.dp)
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = if (completionRate >= 100f) Icons.Default.CheckCircle
                        else Icons.Default.RemoveCircleOutline,
                        contentDescription = null,
                        tint = if (completionRate >= 100f) StatusCompleted else LogticOrange,
                        modifier = Modifier.size(28.dp)
                    )
                }
                
                Spacer(modifier = Modifier.width(12.dp))
                
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = item.name,
                        style = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.Bold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Outlined.CalendarToday,
                            contentDescription = null,
                            tint = LogticGray500,
                            modifier = Modifier.size(14.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text(
                            text = item.date,
                            style = MaterialTheme.typography.bodySmall,
                            color = LogticGray500
                        )
                    }
                }
                
                Column(horizontalAlignment = Alignment.End) {
                    Text(
                        text = item.durationFormatted,
                        style = MaterialTheme.typography.titleSmall,
                        fontWeight = FontWeight.Bold,
                        color = CorpGreen
                    )
                    Text(
                        text = "${item.completedDeliveries}/${item.totalDeliveries}",
                        style = MaterialTheme.typography.bodySmall,
                        color = LogticGray500
                    )
                }
            }
            
            // Barra de progreso
            Spacer(modifier = Modifier.height(12.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                LinearProgressIndicator(
                    progress = { completionRate / 100f },
                    modifier = Modifier
                        .weight(1f)
                        .height(6.dp),
                    color = if (completionRate >= 100f) StatusCompleted else LogticOrange,
                    trackColor = LogticGray200,
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "${completionRate.toInt()}%",
                    style = MaterialTheme.typography.labelSmall,
                    fontWeight = FontWeight.SemiBold,
                    color = if (completionRate >= 100f) StatusCompleted else LogticOrange
                )
            }
            
            // Tiempos si están disponibles
            if (item.startDate != null || item.endDate != null) {
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    if (item.startDate != null) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = Icons.Outlined.PlayCircle,
                                contentDescription = null,
                                tint = LogticGray400,
                                modifier = Modifier.size(14.dp)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = formatHistoryDateTime(item.startDate),
                                style = MaterialTheme.typography.labelSmall,
                                color = LogticGray500
                            )
                        }
                    }
                    if (item.endDate != null) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                imageVector = Icons.Outlined.StopCircle,
                                contentDescription = null,
                                tint = LogticGray400,
                                modifier = Modifier.size(14.dp)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = formatHistoryDateTime(item.endDate),
                                style = MaterialTheme.typography.labelSmall,
                                color = LogticGray500
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun EmptyHistorySection() {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(20.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = LogticGray50)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(48.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = Icons.Outlined.History,
                contentDescription = null,
                tint = LogticGray400,
                modifier = Modifier.size(64.dp)
            )
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = "Sin historial de rutas",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.SemiBold,
                color = LogticGray600
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Aquí aparecerán las rutas que hayas completado",
                style = MaterialTheme.typography.bodyMedium,
                color = LogticGray500,
                textAlign = TextAlign.Center
            )
        }
    }
}

private fun formatDuration(minutes: Double): String {
    return when {
        minutes <= 0 -> "--"
        minutes < 60 -> "${minutes.toInt()}m"
        else -> {
            val hours = (minutes / 60).toInt()
            val mins = (minutes % 60).toInt()
            if (mins > 0) "${hours}h ${mins}m" else "${hours}h"
        }
    }
}

private fun formatHistoryDateTime(dateTime: String): String {
    return try {
        if (dateTime.contains(" ")) {
            dateTime.split(" ").getOrNull(1)?.take(5) ?: dateTime
        } else if (dateTime.contains("T")) {
            dateTime.split("T").getOrNull(1)?.take(5) ?: dateTime
        } else {
            dateTime
        }
    } catch (e: Exception) {
        dateTime
    }
}
