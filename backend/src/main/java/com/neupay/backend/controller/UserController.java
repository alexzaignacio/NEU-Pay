package com.neupay.backend.controller;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.neupay.backend.dto.UserDto;
import com.neupay.backend.service.UserService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/v1")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserDto> me(@AuthenticationPrincipal Jwt jwt) {
        UserDto user = userService.getUserByExternalId(jwt.getSubject());
        return ResponseEntity.ok(user);
    }

    /**
     * Provisions a user based on the JWT claims. If a user with the given external ID already exists, it returns the existing user.
     * If not, it creates a new user using the email and preferred username from the JWT claims. This endpoint is useful for automatically creating user accounts upon first login without requiring a separate registration process.
     * 
     * Note: The email and preferred username claims must be present in the JWT for this endpoint to work correctly. If these claims are missing, the provisioning process may fail or create incomplete user records. It's important to ensure that the authentication provider is configured to include these claims in the issued JWTs.
     * Please refrain from calling this endpoint multiple times with the same JWT, as it may lead to unnecessary database operations. The service will handle idempotency by returning the existing user if one already exists with the same external ID.
     * @param jwt The JWT token containing the user's claims, including the external ID, email, and preferred username.
     * @return A ResponseEntity containing the provisioned UserDto, which includes the user's ID, external ID, email, and display name. If the user already exists, it returns the existing user information.
     * 
     * Please contact Boris Duque if you have any questions or need further clarification about the user provisioning process or the required JWT claims.
     */
    @PostMapping("/me/provision")
    public ResponseEntity<UserDto> provision(@AuthenticationPrincipal Jwt jwt) {
        String email = jwt.getClaimAsString("email");
        String name = jwt.getClaimAsString("preferred_username");
        UserDto user = userService.provisionUser(jwt.getSubject(), email, name);
        return ResponseEntity.ok(user);
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> healthCheck() {
        return ResponseEntity.ok(Map.of("status", "UP", "service", "neupay-backend"));
    }
}
