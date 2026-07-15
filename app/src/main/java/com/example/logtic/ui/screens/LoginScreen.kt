package com.example.logtic.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.logtic.ui.theme.*
import com.example.logtic.viewmodel.AuthViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(
    authViewModel: AuthViewModel,
    onLoginSuccess: () -> Unit
) {
    var passwordVisible by remember { mutableStateOf(false) }
    
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        CorpGreen,           // Verde corporativo
                        CorpDarkGray         // Gris oscuro corporativo
                    )
                )
            )
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Spacer(modifier = Modifier.weight(0.5f))
            
            // Logo circular con fondo dorado
            Box(
                modifier = Modifier
                    .size(120.dp)
                    .clip(CircleShape)
                    .background(CorpGold.copy(alpha = 0.3f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "🚚",
                    fontSize = 56.sp
                )
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            Text(
                text = "LOGTIC",
                fontSize = 40.sp,
                fontWeight = FontWeight.ExtraBold,
                color = LogticWhite,
                letterSpacing = 4.sp
            )
            
            Text(
                text = "Gestión de Rutas Inteligente",
                fontSize = 14.sp,
                color = CorpGold,  // Dorado para mejor visibilidad
                modifier = Modifier.padding(top = 4.dp, bottom = 8.dp)
            )
            
            Text(
                text = "Corporación Crea 21, CA",
                fontSize = 12.sp,
                color = CorpLightBlue,  // Azul grisáceo para visibilidad
                modifier = Modifier.padding(bottom = 48.dp)
            )
            
            // Card de login
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = CardDefaults.cardColors(
                    containerColor = LogticWhite
                ),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Iniciar Sesión",
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold,
                        color = CorpDarkGray,  // Gris oscuro corporativo
                        modifier = Modifier.padding(bottom = 24.dp)
                    )
                    
                    // Campo de usuario
                    OutlinedTextField(
                        value = authViewModel.username.value,
                        onValueChange = { authViewModel.updateUsername(it) },
                        label = { Text("Usuario", color = LogticMediumGray) },
                        leadingIcon = {
                            Icon(
                                imageVector = Icons.Default.Person,
                                contentDescription = "Usuario",
                                tint = CorpGreen  // Verde corporativo
                            )
                        },
                        singleLine = true,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 16.dp),
                        shape = RoundedCornerShape(12.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = CorpGreen,
                            focusedLabelColor = CorpGreen,
                            cursorColor = CorpGreen,
                            unfocusedBorderColor = LogticLightGray,
                            unfocusedLabelColor = LogticMediumGray,
                            focusedTextColor = CorpDarkGray,
                            unfocusedTextColor = CorpDarkGray
                        )
                    )
                    
                    // Campo de contraseña
                    OutlinedTextField(
                        value = authViewModel.password.value,
                        onValueChange = { authViewModel.updatePassword(it) },
                        label = { Text("Contraseña", color = LogticMediumGray) },
                        leadingIcon = {
                            Icon(
                                imageVector = Icons.Default.Lock,
                                contentDescription = "Contraseña",
                                tint = CorpGreen
                            )
                        },
                        trailingIcon = {
                            IconButton(onClick = { passwordVisible = !passwordVisible }) {
                                Icon(
                                    imageVector = if (passwordVisible) Icons.Default.Visibility else Icons.Default.VisibilityOff,
                                    contentDescription = if (passwordVisible) "Ocultar contraseña" else "Mostrar contraseña",
                                    tint = LogticMediumGray
                                )
                            }
                        },
                        visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                        singleLine = true,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 8.dp),
                        shape = RoundedCornerShape(12.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = CorpGreen,
                            focusedLabelColor = CorpGreen,
                            cursorColor = CorpGreen,
                            unfocusedBorderColor = LogticLightGray,
                            unfocusedLabelColor = LogticMediumGray,
                            focusedTextColor = CorpDarkGray,
                            unfocusedTextColor = CorpDarkGray
                        )
                    )
                    
                    // Mensaje de error
                    if (authViewModel.errorMessage.value.isNotEmpty()) {
                        Surface(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 8.dp),
                            shape = RoundedCornerShape(8.dp),
                            color = LogticError.copy(alpha = 0.1f)
                        ) {
                            Text(
                                text = authViewModel.errorMessage.value,
                                color = LogticError,
                                fontSize = 12.sp,
                                textAlign = TextAlign.Center,
                                modifier = Modifier.padding(12.dp)
                            )
                        }
                    }
                    
                    Spacer(modifier = Modifier.height(16.dp))
                    
                    // Botón de login - Dorado corporativo
                    Button(
                        onClick = { authViewModel.login(onLoginSuccess) },
                        enabled = !authViewModel.isLoading.value,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(56.dp),
                        shape = RoundedCornerShape(16.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = CorpGold,  // Dorado corporativo
                            disabledContainerColor = CorpGold.copy(alpha = 0.5f)
                        ),
                        elevation = ButtonDefaults.buttonElevation(
                            defaultElevation = 4.dp,
                            pressedElevation = 8.dp
                        )
                    ) {
                        if (authViewModel.isLoading.value) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(24.dp),
                                color = LogticWhite,
                                strokeWidth = 2.dp
                            )
                        } else {
                            Text(
                                text = "INICIAR SESIÓN",
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                                letterSpacing = 1.sp,
                                color = LogticWhite
                            )
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.weight(1f))
            
            // Footer
            Text(
                text = "v1.0.0 • © 2025 Corpocrea",
                fontSize = 11.sp,
                color = CorpLightBlue,  // Azul grisáceo para visibilidad
                modifier = Modifier.padding(bottom = 16.dp)
            )
        }
    }
}
