package com.example.logtic.ui.components

import android.Manifest
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Base64
import android.util.Log
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import java.io.ByteArrayOutputStream
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

/**
 * Dialog para capturar fotos de entrega
 * Permite usar cámara o galería
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PhotoCaptureDialog(
    partnerName: String,
    onDismiss: () -> Unit,
    onPhotoSelected: (imageBase64: String, notes: String?) -> Unit,
    isUploading: Boolean = false
) {
    val context = LocalContext.current
    var capturedImageBitmap by remember { mutableStateOf<Bitmap?>(null) }
    var capturedImageBase64 by remember { mutableStateOf<String?>(null) }
    var notes by remember { mutableStateOf("") }
    var showImageSourceDialog by remember { mutableStateOf(true) }
    var hasCameraPermission by remember { mutableStateOf(false) }
    var tempImageUri by remember { mutableStateOf<Uri?>(null) }
    
    // Launcher para pedir permiso de cámara
    val cameraPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { isGranted ->
        hasCameraPermission = isGranted
        if (isGranted) {
            // Crear URI temporal y abrir cámara
            tempImageUri = createTempImageUri(context)
        }
    }
    
    // Launcher para tomar foto con cámara
    val takePictureLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.TakePicture()
    ) { success ->
        if (success && tempImageUri != null) {
            val bitmap = loadAndCompressBitmap(context, tempImageUri!!)
            capturedImageBitmap = bitmap
            capturedImageBase64 = bitmapToBase64(bitmap)
            showImageSourceDialog = false
        }
    }
    
    // Launcher para seleccionar de galería
    val pickImageLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.GetContent()
    ) { uri ->
        uri?.let {
            val bitmap = loadAndCompressBitmap(context, it)
            capturedImageBitmap = bitmap
            capturedImageBase64 = bitmapToBase64(bitmap)
            showImageSourceDialog = false
        }
    }
    
    Dialog(
        onDismissRequest = { if (!isUploading) onDismiss() },
        properties = DialogProperties(
            dismissOnBackPress = !isUploading,
            dismissOnClickOutside = !isUploading,
            usePlatformDefaultWidth = false
        )
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth(0.95f)
                .wrapContentHeight(),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.surface
            ),
            elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Header
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = "📸 Foto de Entrega",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.primary
                        )
                        Text(
                            text = partnerName,
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    
                    if (!isUploading) {
                        IconButton(onClick = onDismiss) {
                            Icon(
                                imageVector = Icons.Default.Close,
                                contentDescription = "Cerrar",
                                tint = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
                
                Spacer(modifier = Modifier.height(20.dp))
                
                // Mostrar selector de fuente o imagen capturada
                AnimatedVisibility(
                    visible = showImageSourceDialog && capturedImageBitmap == null,
                    enter = fadeIn(),
                    exit = fadeOut()
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "Selecciona cómo tomar la foto:",
                            fontSize = 16.sp,
                            color = MaterialTheme.colorScheme.onSurface,
                            textAlign = TextAlign.Center
                        )
                        
                        Spacer(modifier = Modifier.height(24.dp))
                        
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceEvenly
                        ) {
                            // Botón Cámara
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                FilledTonalButton(
                                    onClick = {
                                        val permission = Manifest.permission.CAMERA
                                        when {
                                            ContextCompat.checkSelfPermission(
                                                context, permission
                                            ) == android.content.pm.PackageManager.PERMISSION_GRANTED -> {
                                                tempImageUri = createTempImageUri(context)
                                                tempImageUri?.let { takePictureLauncher.launch(it) }
                                            }
                                            else -> {
                                                cameraPermissionLauncher.launch(permission)
                                            }
                                        }
                                    },
                                    modifier = Modifier.size(80.dp),
                                    shape = CircleShape,
                                    colors = ButtonDefaults.filledTonalButtonColors(
                                        containerColor = MaterialTheme.colorScheme.primaryContainer
                                    )
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.CameraAlt,
                                        contentDescription = "Cámara",
                                        modifier = Modifier.size(36.dp),
                                        tint = MaterialTheme.colorScheme.primary
                                    )
                                }
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                    text = "Cámara",
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Medium
                                )
                            }
                            
                            // Botón Galería
                            Column(
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                FilledTonalButton(
                                    onClick = {
                                        pickImageLauncher.launch("image/*")
                                    },
                                    modifier = Modifier.size(80.dp),
                                    shape = CircleShape,
                                    colors = ButtonDefaults.filledTonalButtonColors(
                                        containerColor = MaterialTheme.colorScheme.secondaryContainer
                                    )
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.PhotoLibrary,
                                        contentDescription = "Galería",
                                        modifier = Modifier.size(36.dp),
                                        tint = MaterialTheme.colorScheme.secondary
                                    )
                                }
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                    text = "Galería",
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Medium
                                )
                            }
                        }
                    }
                }
                
                // Mostrar imagen capturada
                AnimatedVisibility(
                    visible = capturedImageBitmap != null,
                    enter = fadeIn(),
                    exit = fadeOut()
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        // Preview de imagen
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(200.dp),
                            shape = RoundedCornerShape(16.dp),
                            elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
                        ) {
                            Box(
                                modifier = Modifier.fillMaxSize(),
                                contentAlignment = Alignment.Center
                            ) {
                                capturedImageBitmap?.let { bitmap ->
                                    Image(
                                        bitmap = bitmap.asImageBitmap(),
                                        contentDescription = "Foto capturada",
                                        modifier = Modifier.fillMaxSize(),
                                        contentScale = ContentScale.Crop
                                    )
                                }
                                
                                // Botón para cambiar foto
                                if (!isUploading) {
                                    IconButton(
                                        onClick = {
                                            capturedImageBitmap = null
                                            capturedImageBase64 = null
                                            showImageSourceDialog = true
                                        },
                                        modifier = Modifier
                                            .align(Alignment.TopEnd)
                                            .padding(8.dp)
                                            .background(
                                                MaterialTheme.colorScheme.surface.copy(alpha = 0.8f),
                                                CircleShape
                                            )
                                    ) {
                                        Icon(
                                            imageVector = Icons.Default.Refresh,
                                            contentDescription = "Cambiar foto",
                                            tint = MaterialTheme.colorScheme.primary
                                        )
                                    }
                                }
                            }
                        }
                        
                        Spacer(modifier = Modifier.height(16.dp))
                        
                        // Campo de notas
                        OutlinedTextField(
                            value = notes,
                            onValueChange = { notes = it },
                            label = { Text("Notas (opcional)") },
                            placeholder = { Text("Ej: Entregado en recepción") },
                            modifier = Modifier.fillMaxWidth(),
                            enabled = !isUploading,
                            maxLines = 2,
                            leadingIcon = {
                                Icon(
                                    imageVector = Icons.Default.Notes,
                                    contentDescription = null
                                )
                            }
                        )
                        
                        Spacer(modifier = Modifier.height(20.dp))
                        
                        // Botones de acción
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            OutlinedButton(
                                onClick = onDismiss,
                                modifier = Modifier.weight(1f),
                                enabled = !isUploading
                            ) {
                                Text("Cancelar")
                            }
                            
                            Button(
                                onClick = {
                                    capturedImageBase64?.let { base64 ->
                                        onPhotoSelected(base64, notes.ifBlank { null })
                                    }
                                },
                                modifier = Modifier.weight(1f),
                                enabled = !isUploading && capturedImageBase64 != null
                            ) {
                                if (isUploading) {
                                    CircularProgressIndicator(
                                        modifier = Modifier.size(20.dp),
                                        strokeWidth = 2.dp,
                                        color = MaterialTheme.colorScheme.onPrimary
                                    )
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text("Subiendo...")
                                } else {
                                    Icon(
                                        imageVector = Icons.Default.CloudUpload,
                                        contentDescription = null,
                                        modifier = Modifier.size(18.dp)
                                    )
                                    Spacer(modifier = Modifier.width(8.dp))
                                    Text("Enviar")
                                }
                            }
                        }
                    }
                }
                
                // Indicador de carga mientras se sube
                if (isUploading && capturedImageBitmap == null) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        CircularProgressIndicator(
                            modifier = Modifier.size(48.dp)
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "Subiendo imagen...",
                            fontSize = 16.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
    
    // Lanzar cámara cuando se obtiene el URI y el permiso
    LaunchedEffect(tempImageUri, hasCameraPermission) {
        if (tempImageUri != null && hasCameraPermission) {
            takePictureLauncher.launch(tempImageUri!!)
        }
    }
}

/**
 * Crear URI temporal para guardar foto de cámara
 */
private fun createTempImageUri(context: Context): Uri {
    val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())
    val imageFileName = "LOGTIC_${timeStamp}.jpg"
    
    // Usar cache interno de la app
    val storageDir = File(context.cacheDir, "images").apply { mkdirs() }
    val imageFile = File(storageDir, imageFileName)
    
    return FileProvider.getUriForFile(
        context,
        "${context.packageName}.fileprovider",
        imageFile
    )
}

/**
 * Cargar y comprimir imagen desde URI
 */
private fun loadAndCompressBitmap(context: Context, uri: Uri): Bitmap? {
    return try {
        val inputStream = context.contentResolver.openInputStream(uri)
        val originalBitmap = BitmapFactory.decodeStream(inputStream)
        inputStream?.close()
        
        // Comprimir y redimensionar si es necesario
        val maxSize = 1024 // Max 1024px en el lado más largo
        val ratio = minOf(
            maxSize.toFloat() / originalBitmap.width,
            maxSize.toFloat() / originalBitmap.height
        )
        
        if (ratio < 1) {
            val newWidth = (originalBitmap.width * ratio).toInt()
            val newHeight = (originalBitmap.height * ratio).toInt()
            Bitmap.createScaledBitmap(originalBitmap, newWidth, newHeight, true)
        } else {
            originalBitmap
        }
    } catch (e: Exception) {
        Log.e("PhotoCapture", "Error loading bitmap: ${e.message}")
        null
    }
}

/**
 * Convertir Bitmap a Base64
 */
private fun bitmapToBase64(bitmap: Bitmap?): String? {
    if (bitmap == null) return null
    
    return try {
        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 80, outputStream) // 80% quality
        val byteArray = outputStream.toByteArray()
        Base64.encodeToString(byteArray, Base64.NO_WRAP)
    } catch (e: Exception) {
        Log.e("PhotoCapture", "Error converting to base64: ${e.message}")
        null
    }
}
