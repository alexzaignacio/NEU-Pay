package com.neupay.backend.dto;

import lombok.Builder;

@Builder
public record UserDto(
    Long id,
    String externalId,
    String email,
    String displayName
) {}
