import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auth_required_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../l10n/app_localizations.dart';

class PlaceFacilityPage extends ConsumerStatefulWidget {
  const PlaceFacilityPage({super.key});

  @override
  ConsumerState<PlaceFacilityPage> createState() => _PlaceFacilityPageState();
}

class _PlaceFacilityPageState extends ConsumerState<PlaceFacilityPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _facilityNameController = TextEditingController();
  final _commentController = TextEditingController();
  PlatformFile? _document;
  bool _isSubmitting = false;
  String? _documentError;
  late Future<List<_VenueRequestSummary>> _myRequestsFuture;

  @override
  void initState() {
    super.initState();
    _myRequestsFuture = _loadMyRequests();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _fullNameController.text = user.fullName;
      final phone = user.phone?.trim();
      if (phone != null && phone.isNotEmpty) {
        _phoneController.text = phone;
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _facilityNameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(AppLocalizations l10n) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp'],
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() {
      _document = result.files.single;
      _documentError = null;
    });
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!ref.read(isLoggedInProvider)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authRequiredHint)),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_document == null || _document!.path == null) {
      setState(() => _documentError = l10n.placeFacilityDocumentRequired);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final formData = FormData.fromMap({
        'full_name': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'facility_name': _facilityNameController.text.trim(),
        if (_commentController.text.trim().isNotEmpty)
          'comment': _commentController.text.trim(),
        'document': await MultipartFile.fromFile(
          _document!.path!,
          filename: _document!.name,
        ),
      });

      await apiClient.post(
        ApiEndpoints.venueRequests,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.placeFacilitySubmitError)),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _facilityNameController.clear();
      _commentController.clear();
      _document = null;
      _documentError = null;
      _myRequestsFuture = _loadMyRequests();
    });
    _showSuccessDialog(l10n);
  }

  Future<List<_VenueRequestSummary>> _loadMyRequests() async {
    final response =
        await ref.read(apiClientProvider).get(ApiEndpoints.venueRequests);
    final data = response.data;
    final rawRequests = data is Map<String, dynamic>
        ? data['requests']
        : data is Map
            ? data['requests']
            : null;
    if (rawRequests is! List) return const [];

    final requests = rawRequests
        .whereType<Map>()
        .map(
          (item) => _VenueRequestSummary.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
    requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return requests;
  }

  void _refreshMyRequests() {
    setState(() {
      _myRequestsFuture = _loadMyRequests();
    });
  }

  void _showSuccessDialog(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.colorMain,
                    AppColors.colorMain.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.colorMain.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.placeFacilitySuccessTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.placeFacilitySuccessMessage,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? const Color(0xFF8B949E) : const Color(0xFF6E7A8A),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.colorMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              l10n.backToHome,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!ref.watch(isLoggedInProvider)) {
      return AuthRequiredScreen(
        title: l10n.placeFacilityTitle,
        description: l10n.authRequiredHint,
      );
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FB);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: bg,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : const Color(0xFF0D1117),
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              l10n.placeFacilityTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0D1117),
              ),
            ),
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlaceFacilityBanner(isDark: isDark, l10n: l10n),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FormField(
                          controller: _fullNameController,
                          label: l10n.fullName,
                          hint: l10n.placeFacilityFullNameHint,
                          icon: Icons.person_outline_rounded,
                          isDark: isDark,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.placeFacilityFullNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          controller: _phoneController,
                          label: l10n.phone,
                          hint: l10n.placeFacilityPhoneHint,
                          icon: Icons.phone_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[\d\s+\-()]'),
                            ),
                          ],
                          validator: (value) {
                            final digits =
                                (value ?? '').replaceAll(RegExp(r'\D'), '');
                            if (digits.isNotEmpty && digits.length < 10) {
                              return l10n.placeFacilityPhoneInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          controller: _facilityNameController,
                          label: l10n.facilityNameLabel,
                          hint: l10n.placeFacilityNameHint,
                          icon: Icons.store_outlined,
                          isDark: isDark,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(l10n),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.placeFacilityNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          controller: _commentController,
                          label: l10n.placeFacilityCommentLabel,
                          hint: l10n.placeFacilityCommentHint,
                          icon: Icons.notes_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),
                        _DocumentPicker(
                          isDark: isDark,
                          fileName: _document?.name,
                          errorText: _documentError,
                          onTap: () => _pickDocument(l10n),
                          l10n: l10n,
                        ),
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: _isSubmitting ? null : () => _submit(l10n),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.colorMain,
                            disabledBackgroundColor:
                                AppColors.colorMain.withValues(alpha: 0.5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.placeFacilityContactButton,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _MyVenueRequestsSection(
                    future: _myRequestsFuture,
                    isDark: isDark,
                    l10n: l10n,
                    onRetry: _refreshMyRequests,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueRequestSummary {
  final String id;
  final String facilityName;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const _VenueRequestSummary({
    required this.id,
    required this.facilityName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _VenueRequestSummary.fromJson(Map<String, dynamic> json) {
    return _VenueRequestSummary(
      id: json['id']?.toString() ?? '',
      facilityName: json['facility_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'created',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime _parseDate(Object? value) {
    if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
    return DateTime.tryParse(value.toString())?.toLocal() ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class _MyVenueRequestsSection extends StatelessWidget {
  final Future<List<_VenueRequestSummary>> future;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onRetry;

  const _MyVenueRequestsSection({
    required this.future,
    required this.isDark,
    required this.l10n,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.placeFacilityMyRequestsTitle,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0D1117),
          ),
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<_VenueRequestSummary>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _MyRequestsContainer(
                isDark: isDark,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return _MyRequestsContainer(
                isDark: isDark,
                child: Column(
                  children: [
                    Text(
                      l10n.placeFacilityLoadRequestsError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.colorError),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: onRetry,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              );
            }

            final requests = snapshot.data ?? const [];
            if (requests.isEmpty) {
              return _MyRequestsContainer(
                isDark: isDark,
                child: Text(
                  l10n.placeFacilityMyRequestsEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF8B949E)
                        : const Color(0xFF6E7A8A),
                  ),
                ),
              );
            }

            return Column(
              children: [
                for (final request in requests) ...[
                  _VenueRequestCard(
                    request: request,
                    isDark: isDark,
                    l10n: l10n,
                  ),
                  if (request != requests.last) const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MyRequestsContainer extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _MyRequestsContainer({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Center(child: child),
    );
  }
}

class _VenueRequestCard extends StatelessWidget {
  final _VenueRequestSummary request;
  final bool isDark;
  final AppLocalizations l10n;

  const _VenueRequestCard({
    required this.request,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor =
        isDark ? const Color(0xFF8B949E) : const Color(0xFF6E7A8A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  request.facilityName.isEmpty ? '—' : request.facilityName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0D1117),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _VenueRequestStatusBadge(
                status: request.status,
                l10n: l10n,
                isDark: isDark,
              ),
            ],
          ),
          if (_statusMessage(request.status, l10n) case final message?) ...[
            const SizedBox(height: 12),
            _VenueRequestStatusCallout(
              status: request.status,
              message: message,
              isDark: isDark,
            ),
          ],
          const SizedBox(height: 14),
          _DateLine(
            icon: Icons.send_outlined,
            label: l10n.placeFacilitySentAt,
            value: _formatDate(context, request.createdAt),
            color: mutedColor,
          ),
          const SizedBox(height: 8),
          _DateLine(
            icon: Icons.update_rounded,
            label: l10n.placeFacilityUpdatedAt,
            value: _formatDate(context, request.updatedAt),
            color: mutedColor,
          ),
        ],
      ),
    );
  }
}

class _DateLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DateLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _VenueRequestStatusBadge extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;
  final bool isDark;

  const _VenueRequestStatusBadge({
    required this.status,
    required this.l10n,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final style = _statusBadgeStyle(status, isDark);
    final label = _statusLabel(status, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(style.borderRadius),
        border: style.borderColor == null
            ? null
            : Border.all(color: style.borderColor!, width: 1.2),
        boxShadow: style.boxShadow,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: style.foregroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: style.letterSpacing,
        ),
      ),
    );
  }
}

class _StatusBadgeStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final double letterSpacing;

  const _StatusBadgeStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderRadius,
    this.borderColor,
    this.boxShadow,
    this.letterSpacing = 0,
  });
}

_StatusBadgeStyle _statusBadgeStyle(String status, bool isDark) {
  return switch (status) {
    'awaiting' => _StatusBadgeStyle(
        backgroundColor: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.2 : 0.14),
        foregroundColor:
            isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
        borderRadius: 999,
        borderColor: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.55 : 0.45),
      ),
    'reviewing' => _StatusBadgeStyle(
        backgroundColor: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.22 : 0.14),
        foregroundColor:
            isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
        borderRadius: 8,
        borderColor: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.5 : 0.35),
      ),
    'approved' => _StatusBadgeStyle(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        borderRadius: 999,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.45 : 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    'cancelled' => _StatusBadgeStyle(
        backgroundColor: AppColors.colorError.withValues(alpha: isDark ? 0.18 : 0.1),
        foregroundColor:
            isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
        borderRadius: 6,
        borderColor: AppColors.colorError.withValues(alpha: isDark ? 0.65 : 0.55),
        letterSpacing: 0.2,
      ),
    'created' => _StatusBadgeStyle(
        backgroundColor: AppColors.colorMain,
        foregroundColor: Colors.white,
        borderRadius: 10,
        boxShadow: [
          BoxShadow(
            color: AppColors.colorMain.withValues(alpha: isDark ? 0.45 : 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    _ => _StatusBadgeStyle(
        backgroundColor: const Color(0xFF6B7280).withValues(alpha: isDark ? 0.22 : 0.14),
        foregroundColor:
            isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
        borderRadius: 999,
      ),
  };
}

class _VenueRequestStatusCallout extends StatelessWidget {
  final String status;
  final String message;
  final bool isDark;

  const _VenueRequestStatusCallout({
    required this.status,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _statusAccentColor(status);
    final icon = _statusCalloutIcon(status);
    final textColor = _statusCalloutTextColor(status, isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: isDark ? 0.16 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.38 : 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isDark ? 0.24 : 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusAccentColor(String status) {
  return switch (status) {
    'awaiting' => const Color(0xFFF59E0B),
    'reviewing' => const Color(0xFF3B82F6),
    'approved' => const Color(0xFF10B981),
    'cancelled' => AppColors.colorError,
    'created' => AppColors.colorMain,
    _ => const Color(0xFF6B7280),
  };
}

IconData _statusCalloutIcon(String status) {
  return switch (status) {
    'approved' => Icons.check_circle_outline_rounded,
    'created' => Icons.storefront_outlined,
    'cancelled' => Icons.info_outline_rounded,
    _ => Icons.info_outline_rounded,
  };
}

Color _statusCalloutTextColor(String status, bool isDark) {
  if (isDark) {
    return switch (status) {
      'approved' => const Color(0xFF6EE7B7),
      'created' => const Color(0xFF5EEAD4),
      'cancelled' => const Color(0xFFFCA5A5),
      _ => const Color(0xFFCBD5E1),
    };
  }
  return switch (status) {
    'approved' => const Color(0xFF047857),
    'created' => const Color(0xFF0F766E),
    'cancelled' => const Color(0xFFB91C1C),
    _ => const Color(0xFF374151),
  };
}

String _statusLabel(String status, AppLocalizations l10n) {
  switch (status) {
    case 'awaiting':
      return l10n.venueRequestStatusAwaiting;
    case 'reviewing':
      return l10n.venueRequestStatusReviewing;
    case 'approved':
      return l10n.venueRequestStatusApproved;
    case 'cancelled':
      return l10n.venueRequestStatusCancelled;
    case 'created':
    default:
      return l10n.venueRequestStatusCreated;
  }
}

String? _statusMessage(String status, AppLocalizations l10n) {
  switch (status) {
    case 'approved':
      return l10n.venueRequestStatusApprovedMessage;
    case 'created':
      return l10n.venueRequestStatusCreatedMessage;
    case 'cancelled':
      return l10n.venueRequestStatusRejectedMessage;
    default:
      return null;
  }
}

String _formatDate(BuildContext context, DateTime date) {
  if (date.millisecondsSinceEpoch == 0) return '—';
  final locale = Localizations.localeOf(context).toString();
  return DateFormat('d MMM yyyy, HH:mm', locale).format(date);
}

class _PlaceFacilityBanner extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l10n;

  const _PlaceFacilityBanner({required this.isDark, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E4B), Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.colorMain.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.store_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.placeFacilitySubtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isDark;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onFieldSubmitted,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          maxLines: maxLines,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0D1117),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
            prefixIcon: Icon(icon, color: AppColors.colorMain, size: 22),
            filled: true,
            fillColor: fillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.colorMain, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.colorError),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.colorError, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentPicker extends StatelessWidget {
  final bool isDark;
  final String? fileName;
  final String? errorText;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _DocumentPicker({
    required this.isDark,
    required this.fileName,
    required this.errorText,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = errorText != null
        ? AppColors.colorError
        : isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.06);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.placeFacilityDocumentLabel,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: borderColor,
                width: errorText != null ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.attach_file_rounded,
                  color: AppColors.colorMain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName ?? l10n.placeFacilityDocumentHint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fileName == null
                          ? (isDark ? Colors.white38 : Colors.grey.shade500)
                          : (isDark ? Colors.white : const Color(0xFF0D1117)),
                      fontWeight:
                          fileName == null ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.placeFacilityDocumentAction,
                  style: const TextStyle(
                    color: AppColors.colorMain,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(color: AppColors.colorError, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
