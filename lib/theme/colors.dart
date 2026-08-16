import 'package:flutter/material.dart';

// Brand tokens — TMS Redesign (forest-green visual language), ported 1:1 from the
// Android app's ui/theme/Color.kt (claude.ai/design project "TMS Redesign.dc.html").
const tracGoGreen = Color(0xFF2F5A3F);
const tracGoGreenDark = Color(0xFF1F3B2C);
const tracGoGreenLight = Color(0xFFEAF3E4);
const tracGoGreenLightAlt = Color(0xFFDCEFD3);
const tracGoLoginAccentGreen = Color(0xFF8FD98F);

const tracGoTextDark = Color(0xFF16231A);
const tracGoTextMuted = Color(0xFF7A857E);
const tracGoTextMutedAlt = Color(0xFF8A938C);
const tracGoTextSubtle = Color(0xFF5B6660);
const tracGoPlaceholder = Color(0xFFB8BFB6);

const tracGoBorder = Color(0xFFE3E9DF);
const tracGoDivider = Color(0xFFEDF0EA);
const tracGoInputBackground = Color(0xFFFAFCF9);
const tracGoScreenBackground = Color(0xFFF6F8F5);
const tracGoPageBackground = Color(0xFFF0F3EE);
const tracGoSurfaceWhite = Color(0xFFFFFFFF);

// Requisition status accents (Dashboard stat panel / status pills).
const tracGoStatusAllPurple = Color(0xFF7C5CD1);
const tracGoStatusAllPurpleBg = Color(0xFFEFEAFB);
const tracGoStatusApprovedGreen = Color(0xFF2F8F4E);
const tracGoStatusApprovedGreenBg = Color(0xFFE1F3E0);
const tracGoStatusAssignedTeal = Color(0xFF147A6B);
const tracGoStatusAssignedTealBg = Color(0xFFDCF3EF);
const tracGoStatusPendingOrange = Color(0xFFB08414);
const tracGoStatusPendingOrangeText = Color(0xFF9A6A0A);
const tracGoStatusPendingOrangeBg = Color(0xFFFDF3DD);
const tracGoStatusRejectedRed = Color(0xFFB23B30);
const tracGoStatusRejectedRedBg = Color(0xFFFBE4E2);

// "Requisition Summary" card (claude.ai/design project "Requisition Summary.dc.html").
// The All Requisitions hero tile carries its own violet ramp, which sits outside the
// status-accent pairs above and is only used there.
const tracGoStatHeroGradientTop = Color(0xFFF5F2FF);
const tracGoStatHeroGradientBottom = Color(0xFFF9F7FF);
const tracGoStatHeroAccent = Color(0xFF6B4EE6);
const tracGoStatHeroBadgeBg = Color(0xFFE7E0FF);
const tracGoStatHeroLabel = Color(0xFF4B3E7A);
const tracGoStatHeroCount = Color(0xFF241C42);

/// Backing for the four status tiles — a hair warmer than [tracGoSurfaceWhite] so the
/// tiles read as insets inside the white card rather than merging with it.
const tracGoStatTileBackground = Color(0xFFFBFCFB);

// Destructive actions (Cancel, Log Out) — distinct, brighter red from the "Rejected"
// status semantic color above, per the redesign mock.
const tracGoDestructiveRed = Color(0xFFC4453A);

const tracGoLauncherNavy = Color(0xFF1B213B);
