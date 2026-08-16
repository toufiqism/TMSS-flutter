import 'package:flutter/material.dart';

// Brand tokens — "daylight" redesign, ported from the claude.ai/design project
// "TracGo App Screens.dc.html" (and its companion "TracGo Sign In.dc.html").
//
// This replaced the forest-green palette the app inherited 1:1 from the native Android
// app's ui/theme/Color.kt. The two are no longer in sync, deliberately: the daylight
// language is navy ink on a warm off-white page, with green reserved for actions and a
// lime accent used sparingly. Values are taken verbatim from the design — do not
// "tidy" them towards the old Android constants.

/// Action green. Buttons, links, selected accents, step badges.
const tracGoGreen = Color(0xFF2E5C34);

/// Pressed/hover state of [tracGoGreen].
const tracGoGreenDark = Color(0xFF24492A);

/// Lime accent. Used once per surface at most: the drawer avatar, the hamburger's third
/// rule, the radial glow on dark cards, the "approved" dot.
const tracGoLime = Color(0xFF7AB648);

/// `rgba(122,182,72,0.16)` — the month badge on the dashboard.
const tracGoLimeTint = Color(0x297AB648);

/// `rgba(122,182,72,0.18)` — selected pill chips (trip type, capacity, required for).
const tracGoLimeTintStrong = Color(0x2E7AB648);

/// Navy ink. Headings, values, dark hero cards, the drawer header, the selected segment.
const tracGoInk = Color(0xFF12122B);

/// Alias kept so every existing `tracGoTextDark` call site keeps meaning "primary text".
const tracGoTextDark = tracGoInk;

/// Body copy and the labels beside step badges.
const tracGoTextBody = Color(0xFF4A5148);

/// Secondary copy — subtitles, unselected pill labels, drawer rows.
const tracGoTextMuted = Color(0xFF6B7269);

/// Same value as [tracGoTextBody]; kept as its own name because the design uses it for
/// "quieter than ink, louder than muted" captions rather than running text.
const tracGoTextSubtle = Color(0xFF4A5148);

/// Micro-labels — the uppercase section captions and field labels.
const tracGoTextMutedAlt = Color(0xFF8D948B);

/// Row supporting text ("Today, 10:00 AM · Client pickup").
const tracGoTextFaint = Color(0xFF7A8179);

const tracGoPlaceholder = Color(0xFFA2A9A0);

/// Card outline. One hairline, never a shadow, on every white surface.
const tracGoBorder = Color(0xFFE8EAE3);

/// The hairline *inside* a card, between stacked rows. Lighter than [tracGoBorder] on
/// purpose — an inner rule at the outline's weight makes the card read as a table.
const tracGoDivider = Color(0xFFF0F1EC);

/// Inset fields (search boxes, unselected pill chips) sitting on white.
const tracGoInputBackground = Color(0xFFF4F5F0);

const tracGoScreenBackground = Color(0xFFF4F5F0);
const tracGoPageBackground = Color(0xFFF4F5F0);
const tracGoSurfaceWhite = Color(0xFFFFFFFF);

/// Neutral tint for avatars, icon wells and selected drawer rows.
const tracGoSurfaceSoft = Color(0xFFF1F3EC);

/// Sign In only — a warmer white than [tracGoPageBackground], per the Sign In design.
const tracGoSignInBackground = Color(0xFFFBFBF7);

/// The Sign In field rule.
const tracGoRule = Color(0xFFDDE0DA);

/// Dashed outline on an empty slot ("no driver or vehicle assigned yet").
const tracGoDashedBorder = Color(0xFFD3D7CD);

/// Dashed outline on an *actionable* empty slot ("+ Add" employee).
const tracGoDashedAccentBorder = Color(0xFFC6CFC0);

// Requisition status accents. Each status is a text/background pair for the pill plus a
// saturated dot used on list rows and the activity timeline, where a full pill would be
// too loud.
const tracGoStatusPendingText = Color(0xFF7A5A00);
const tracGoStatusPendingBg = Color(0xFFFBF0D5);
const tracGoStatusPendingDot = Color(0xFFE0A82E);

const tracGoStatusApprovedText = Color(0xFF2E5C34);
const tracGoStatusApprovedBg = Color(0xFFE2EFDE);
const tracGoStatusApprovedDot = Color(0xFF7AB648);

const tracGoStatusAssignedText = Color(0xFF22254F);
const tracGoStatusAssignedBg = Color(0xFFE5E7F1);
const tracGoStatusAssignedDot = Color(0xFF3D4189);

const tracGoStatusRejectedText = Color(0xFF8C3E38);
const tracGoStatusRejectedBg = Color(0xFFF6E5E2);
const tracGoStatusRejectedDot = Color(0xFFA4413A);

/// Cancelled, and any status this build does not recognise. Neither carries a semantic
/// colour in the design — cancelled is a terminal non-event — so both read as neutral
/// rather than borrowing another status's meaning.
const tracGoStatusNeutralText = Color(0xFF5A6058);
const tracGoStatusNeutralBg = Color(0xFFE8EAE3);
const tracGoStatusNeutralDot = Color(0xFFB9BEB5);

/// Destructive actions (Cancel, Log Out). Deliberately the same hue family as
/// [tracGoStatusRejectedDot] but darker, so a red button never reads as a status.
const tracGoDestructiveRed = Color(0xFFA4413A);

/// `rgba(164,65,58,0.1)` — the profile screen's Log out button fill.
const tracGoDestructiveRedTint = Color(0x1AA4413A);

/// The scrim behind the navigation drawer, `rgba(18,18,43,0.42)`.
const tracGoScrim = Color(0x6B12122B);
