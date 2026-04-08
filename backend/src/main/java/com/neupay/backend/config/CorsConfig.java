package com.neupay.backend.config;

import java.util.List;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
public class CorsConfig {
    
    /**
     * CORS configuration to allow requests from specified origins, with support for common HTTP methods and headers.
     * The allowed origins can be configured via the 'app.cors.allowed-origins' property, defaulting to localhost for development.
     * This configuration ensures that the frontend can communicate with the backend without CORS issues, while also allowing for secure cross-origin requests in production environments.
     * 
     * Note: In a production environment, it's important to restrict the allowed origins to only those that are necessary for security reasons.
     * When deployed in GCP Cloud Run, the frontend URL should be added to the allowed origins to ensure proper communication between the frontend and backend services. 
     */
    @Value("${app.cors.allowed-origins:http://localhost:3000,http://localhost:8080}")
    private List<String> allowedOrigins;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(allowedOrigins);
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("Authorization", "Content-Type", "Accept", "X-Requested-With"));
        config.setExposedHeaders(List.of("Authorization"));
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
