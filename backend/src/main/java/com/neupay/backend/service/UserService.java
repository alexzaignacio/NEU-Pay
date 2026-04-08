package com.neupay.backend.service;

import org.springframework.stereotype.Service;

import com.neupay.backend.dto.UserDto;
import com.neupay.backend.exception.ResourceNotFoundException;
import com.neupay.backend.model.User;
import com.neupay.backend.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public UserDto getUserByExternalId(String externalId) {
        User user = userRepository.findByExternalId(externalId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + externalId));
        return toDto(user);
    }

    public UserDto provisionUser(String externalId, String email, String displayName) {
        return userRepository.findByExternalId(externalId)
                .map(this::toDto)
                .orElseGet(() -> {
                    User newUser = User.builder()
                            .externalId(externalId)
                            .email(email)
                            .displayName(displayName)
                            .build();
                    return toDto(userRepository.save(newUser));
                });
    }

    private UserDto toDto(User user) {
        return UserDto.builder()
                .id(user.getId())
                .externalId(user.getExternalId())
                .email(user.getEmail())
                .displayName(user.getDisplayName())
                .build();
    }
}
