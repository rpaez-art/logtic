package com.example.logtic.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.logtic.data.DriverWithRoutes
import com.example.logtic.data.Route
import com.example.logtic.data.RouteStatus
import com.example.logtic.viewmodel.DriverMonitorViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DriverMonitorScreen(
    driverMonitorViewModel: DriverMonitorViewModel,
    onBack: () -> Unit
) {
    var selectedDriver by remember { mutableStateOf<DriverWithRoutes?>(null) }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { 
                    Text(
                        text = if (selectedDriver == null) "Monitor de Choferes" else "Rutas de ${selectedDriver?.driver?.fullName}",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold
                    )
                },
                navigationIcon = {
                    IconButton(onClick = {
                        if (selectedDriver != null) {
                            selectedDriver = null
                        } else {
                            onBack()
                        }
                    }) {
                        Icon(
                            imageVector = Icons.Default.ArrowBack,
                            contentDescription = "Volver"
                        )
                    }
                },
                actions = {
                    IconButton(onClick = { driverMonitorViewModel.refreshData() }) {
                        Icon(
                            imageVector = Icons.Default.Refresh,
                            contentDescription = "Actualizar"
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                )
            )
        }
    ) { padding ->
        if (selectedDriver == null) {
            // Vista de lista de choferes
            DriversListView(
                drivers = driverMonitorViewModel.driversWithRoutes.value,
                onDriverClick = { selectedDriver = it },
                modifier = Modifier.padding(padding)
            )
        } else {
            // Vista de detalle de rutas del chofer
            DriverRoutesDetailView(
                driverWithRoutes = selectedDriver!!,
                modifier = Modifier.padding(padding)
            )
        }
    }
}

@Composable
fun DriversListView(
    drivers: List<DriverWithRoutes>,
    onDriverClick: (DriverWithRoutes) -> Unit,
    modifier: Modifier = Modifier
) {
    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        items(drivers) { driverWithRoutes ->
            DriverCard(
                driverWithRoutes = driverWithRoutes,
                onClick = { onDriverClick(driverWithRoutes) }
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DriverCard(
    driverWithRoutes: DriverWithRoutes,
    onClick: () -> Unit
) {
    Card(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp)
        ) {
            // Header con nombre del chofer
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(bottom = 12.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.LocalShipping,
                    contentDescription = null,
                    modifier = Modifier.size(40.dp),
                    tint = MaterialTheme.colorScheme.primary
                )
                Spacer(modifier = Modifier.width(12.dp))
                Column {
                    Text(
                        text = driverWithRoutes.driver.fullName,
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Rol: ${driverWithRoutes.driver.role}",
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
            
            // Progress bar
            Column(modifier = Modifier.padding(vertical = 8.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = "Progreso",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium
                    )
                    Text(
                        text = "${driverWithRoutes.completionPercentage}%",
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.primary
                    )
                }
                Spacer(modifier = Modifier.height(4.dp))
                LinearProgressIndicator(
                    progress = { driverWithRoutes.completionPercentage / 100f },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(8.dp),
                    color = MaterialTheme.colorScheme.primary,
                    trackColor = MaterialTheme.colorScheme.surfaceVariant,
                )
            }
            
            // Estadísticas
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceAround
            ) {
                StatItem(
                    label = "Total",
                    value = driverWithRoutes.totalRoutes.toString(),
                    color = MaterialTheme.colorScheme.primary
                )
                StatItem(
                    label = "En Curso",
                    value = driverWithRoutes.inProgressRoutes.toString(),
                    color = MaterialTheme.colorScheme.secondary
                )
                StatItem(
                    label = "Completadas",
                    value = driverWithRoutes.completedRoutes.toString(),
                    color = MaterialTheme.colorScheme.tertiary
                )
                StatItem(
                    label = "Pendientes",
                    value = driverWithRoutes.pendingRoutes.toString(),
                    color = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}

@Composable
fun StatItem(
    label: String,
    value: String,
    color: androidx.compose.ui.graphics.Color
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value,
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold,
            color = color
        )
        Text(
            text = label,
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
fun DriverRoutesDetailView(
    driverWithRoutes: DriverWithRoutes,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    
    Column(
        modifier = modifier
            .fillMaxSize()
    ) {
        // Resumen
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.secondaryContainer
            )
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceAround
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = driverWithRoutes.completedRoutes.toString(),
                        fontSize = 32.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSecondaryContainer
                    )
                    Text(
                        text = "Completadas",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSecondaryContainer
                    )
                }
                
                HorizontalDivider(
                    modifier = Modifier
                        .height(50.dp)
                        .width(1.dp)
                )
                
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = driverWithRoutes.pendingRoutes.toString(),
                        fontSize = 32.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSecondaryContainer
                    )
                    Text(
                        text = "Pendientes",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSecondaryContainer
                    )
                }
            }
        }
        
        // Lista de rutas
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(driverWithRoutes.routes) { route ->
                AdminRouteCard(
                    route = route,
                    onViewLocation = { lat, lon ->
                        val uri = Uri.parse("geo:$lat,$lon?q=$lat,$lon")
                        val intent = Intent(Intent.ACTION_VIEW, uri)
                        intent.setPackage("com.google.android.apps.maps")
                        if (intent.resolveActivity(context.packageManager) != null) {
                            context.startActivity(intent)
                        }
                    }
                )
            }
        }
    }
}

@Composable
fun AdminRouteCard(
    route: Route,
    onViewLocation: (Double, Double) -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        colors = CardDefaults.cardColors(
            containerColor = when (route.status) {
                RouteStatus.COMPLETED -> MaterialTheme.colorScheme.tertiaryContainer
                RouteStatus.IN_PROGRESS -> MaterialTheme.colorScheme.secondaryContainer
                else -> MaterialTheme.colorScheme.surface
            }
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
                Text(
                    text = route.clientName,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold
                )
                Surface(
                    shape = MaterialTheme.shapes.small,
                    color = when (route.status) {
                        RouteStatus.COMPLETED -> MaterialTheme.colorScheme.tertiary
                        RouteStatus.IN_PROGRESS -> MaterialTheme.colorScheme.secondary
                        else -> MaterialTheme.colorScheme.primary
                    }
                ) {
                    Text(
                        text = when (route.status) {
                            RouteStatus.COMPLETED -> "✓ Completada"
                            RouteStatus.IN_PROGRESS -> "→ En Curso"
                            else -> "○ Pendiente"
                        },
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onPrimary,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = "${route.address}, ${route.city}",
                fontSize = 13.sp,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            if (route.startTime != null) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "⏰ Inicio: ${route.startTime}",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            
            if (route.endTime != null) {
                Text(
                    text = "✓ Fin: ${route.endTime}",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                
                if (route.endLatitude != null && route.endLongitude != null) {
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedButton(
                        onClick = { onViewLocation(route.endLatitude, route.endLongitude) },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Icon(
                            imageVector = Icons.Default.LocationOn,
                            contentDescription = null,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("Ver Ubicación Final", fontSize = 12.sp)
                    }
                }
            }
        }
    }
}
