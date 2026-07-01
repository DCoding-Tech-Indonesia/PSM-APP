import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/notification/approval_refresh_notifier.dart';
import 'package:psm_mobile/core/presentations/widgets/core_blur_dialog.dart';
import 'package:psm_mobile/core/presentations/widgets/core_button.dart';
import 'package:psm_mobile/core/presentations/widgets/core_dropdown_search.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/reference/reference_data_source.dart';
import 'package:psm_mobile/features/spm/data/datasources/spm_remote_data_source.dart';
import 'package:psm_mobile/features/spm/data/models/spm_question_model.dart';
import 'package:psm_mobile/features/spm/data/repositories/spm_repository_impl.dart';
import 'package:psm_mobile/features/spm/presentation/bloc/spm_input/spm_input_bloc.dart';
import 'package:psm_mobile/features/spm/presentation/bloc/spm_input/spm_input_event.dart';
import 'package:psm_mobile/features/spm/presentation/bloc/spm_input/spm_input_state.dart';

// ─── Halaman Utama Input SPM ───────────────────────────────────────────────────
class SpmInputScreen extends StatelessWidget {
  const SpmInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SpmInputBloc(
        repository: SpmRepositoryImpl(
          remoteDataSource: SpmRemoteDataSource(dio: DioClient().instance),
        ),
      ),
      child: const SpmInputScreenView(),
    );
  }
}

class SpmInputScreenView extends StatefulWidget {
  const SpmInputScreenView({super.key});

  @override
  State<SpmInputScreenView> createState() => _SpmInputScreenViewState();
}

class _SpmInputScreenViewState extends State<SpmInputScreenView> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0: Identitas, 1: Pertanyaan, 2: Summary

  late final ReferenceDataSource _referenceDataSource;

  // ── Step 1: Identitas ─────────────────────────────────────────────────────
  ReferenceDetail? _selectedKoridor;
  ReferenceDetail? _selectedTipePemeriksaan;
  ReferenceDetail? _selectedHalte;
  ReferenceDetail? _selectedBus;
  bool _isLoadingKoridor = false;
  bool _isLoadingTipe = false;
  bool _isLoadingHalte = false;
  bool _isLoadingBus = false;

  List<ReferenceDetail> _listKoridor = [];
  List<ReferenceDetail> _listTipePemeriksaan = [];
  List<ReferenceDetail> _listHalte = [];
  List<ReferenceDetail> _listBus = [];

  bool get _isIdentitasValid {
    if (_selectedTipePemeriksaan?.code == 'HALTE') {
      return _selectedKoridor != null &&
          _selectedTipePemeriksaan != null &&
          _selectedHalte != null;
    } else if (_selectedTipePemeriksaan?.code == 'BUS') {
      return _selectedKoridor != null &&
          _selectedTipePemeriksaan != null &&
          _selectedBus != null;
    }
    return _selectedKoridor != null && _selectedTipePemeriksaan != null;
  }

  // ── Step 2: Pertanyaan ────────────────────────────────────────────────────
  List<SpmQuestionModel> _pertanyaan = [];
  List<String> _kategoriList = [];
  int _currentKategoriIndex = 0;
  int _currentQuestionIndex = 0;

  List<SpmQuestionModel> get _currentKategoriQuestions {
    if (_kategoriList.isEmpty) return [];
    final currentKategori = _kategoriList[_currentKategoriIndex].toLowerCase();
    return _pertanyaan
        .where((q) => q.categorySPM.name.toLowerCase() == currentKategori)
        .toList();
  }

  SpmQuestionModel? get _currentQuestion {
    final qs = _currentKategoriQuestions;
    if (qs.isEmpty || _currentQuestionIndex >= qs.length) return null;
    return qs[_currentQuestionIndex];
  }

  @override
  void initState() {
    super.initState();
    _referenceDataSource = ReferenceDataSource(dio: DioClient().instance);
    _loadKoridor();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Data Loaders (Reference data tetap di UI karena bersifat ephemeral) ──
  Future<void> _loadKoridor() async {
    setState(() => _isLoadingKoridor = true);
    try {
      final result = await _referenceDataSource.fetchReferenceKoridor('');
      if (mounted) {
        setState(() {
          _listKoridor = result;
          _isLoadingKoridor = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingKoridor = false);
    }
  }

  Future<void> _loadTipePemeriksaan() async {
    setState(() {
      _isLoadingTipe = true;
      _listTipePemeriksaan = [];
      _selectedTipePemeriksaan = null;
    });
    try {
      final result = await _referenceDataSource.fetchReferenceObjectTypeSpm('');
      if (mounted) {
        setState(() {
          _listTipePemeriksaan = result;
          _isLoadingTipe = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTipe = false);
    }
  }

  Future<void> _loadHalte() async {
    setState(() => _isLoadingHalte = true);
    try {
      final result = await _referenceDataSource.fetchReferenceLokasiHalte(
        '',
        _selectedKoridor!.id,
      );
      if (mounted) {
        setState(() {
          _listHalte = result;
          _isLoadingHalte = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingHalte = false);
    }
  }

  Future<void> _loadBus() async {
    setState(() => _isLoadingBus = true);
    try {
      final result = await _referenceDataSource.fetchReferenceBus(
        '',
        _selectedKoridor!.id,
      );
      if (mounted) {
        setState(() {
          _listBus = result;
          _isLoadingBus = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingBus = false);
    }
  }

  void _fetchPertanyaanAndGoNext() {
    context.read<SpmInputBloc>().add(
      FetchQuestions(_selectedTipePemeriksaan!.id),
    );
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _nextQuestion() {
    final isLastQuestionInKategori =
        _currentQuestionIndex >= _currentKategoriQuestions.length - 1;
    final isLastKategori = _currentKategoriIndex >= _kategoriList.length - 1;

    if (!isLastQuestionInKategori) {
      setState(() => _currentQuestionIndex++);
    } else if (!isLastKategori) {
      _showLanjutDialog();
    } else {
      _goToStep(2);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    } else if (_currentKategoriIndex > 0) {
      setState(() {
        _currentKategoriIndex--;
        final prevKategori = _kategoriList[_currentKategoriIndex].toLowerCase();
        _currentQuestionIndex =
            _pertanyaan
                .where((q) => q.categorySPM.name.toLowerCase() == prevKategori)
                .length -
            1;
      });
    } else {
      _goToStep(0);
    }
  }

  void _showLanjutDialog() {
    showCoreConfirmDialog(
      context: context,
      title: 'Kategori Selesai',
      message:
          'Kategori "${_kategoriList[_currentKategoriIndex]}" telah selesai.\nLanjut ke kategori berikutnya?',
      onConfirm: () {
        setState(() {
          _currentKategoriIndex++;
          _currentQuestionIndex = 0;
        });
      },
    );
  }

  void _showSubmitDialog() {
    showCoreConfirmDialog(
      context: context,
      title: 'Simpan Data',
      message: 'Ingin simpan data sebagai draft?',
      onConfirm: () {
        // context.pop();
        _submitSpm();
      },
    );
  }

  void _submitSpm() {
    final payload = {
      "idKoridor": _selectedKoridor?.id,
      "idTypePemeriksaan": _selectedTipePemeriksaan?.id,
      if (_selectedBus != null) "idBus": _selectedBus!.id,
      if (_selectedHalte != null) "idHalte": _selectedHalte!.id,
      "detail": _pertanyaan
          .map(
            (res) => {
              "idIndikatorSPM": res.id,
              "nilaiCapaian": res.nilaiInput ?? 0.0,
              "bobotCapaian": res.bobotCapaian,
              "nilaiStandar": res.targetCapaian,
            },
          )
          .toList(),
    };

    context.read<SpmInputBloc>().add(CreateSpmData(payload));
  }

  void _showWorkflowSubmitDialog(BuildContext context, int idAuditTrail) {
    final TextEditingController reasonController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).cardTheme.color?.withValues(alpha: 0.9) ??
                    Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Konfirmasi Submit',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Apakah Anda yakin ingin melakukan submit data ini? Silakan isi alasan di bawah ini:',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Masukkan alasan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor.withValues(alpha: 0.5),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Alasan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              if (mounted) {
                                context.pop(true);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.pop(dialogContext);
                                context.read<SpmInputBloc>().add(
                                  SubmitSpmCreated(
                                    idAuditTrail: idAuditTrail,
                                    reason: reasonController.text,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SpmInputBloc, SpmInputState>(
      listener: (context, state) {
        if (state is QuestionsLoaded) {
          setState(() {
            _pertanyaan = state.questions;
            _kategoriList = state.questions
                .map((q) => q.categorySPM.name)
                .toSet()
                .toList();
            _currentKategoriIndex = 0;
            _currentQuestionIndex = 0;
          });
          _goToStep(1);
        } else if (state is QuestionsError) {
          showCoreErrorDialog(
            context,
            'Gagal memuat pertanyaan SPM',
            state.message,
          );
        } else if (state is SpmCreateSuccess) {
          showCoreSuccessDialog(
            context,
            'Sukses',
            'Data SPM berhasil disimpan',
          );
          _showWorkflowSubmitDialog(context, state.auditTrailId);
        } else if (state is SpmCreateError) {
          showCoreErrorDialog(
            context,
            'Gagal menyimpan data SPM',
            state.message,
          );
        } else if (state is SpmSubmitSuccess) {
          // showCoreSuccessDialog(context, 'Sukses', state.message);
          // context.pop(true);
          Navigator.of(context, rootNavigator: true).pop();

          final router = GoRouter.of(context);

          showCoreSuccessDialog(
            context,
            'Sukses',
            state.message, // Menggunakan pesan dari API
          ).then((_) {
            // Refresh notifier data list
            ApprovalRefreshNotifier.instance.notifyRefresh();

            // 4. Lakukan pop pada halaman utama untuk kembali ke halaman list
            if (router.canPop()) {
              router.pop(true);
            }
          });
        } else if (state is SpmSubmitError) {
          showCoreErrorDialog(context, 'Gagal Submit', state.message);
          context.pop(true);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_currentStep > 0) {
            _goToStep(_currentStep - 1);
          } else {
            context.pop();
          }
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // ── App Bar ──────────────────────────────────────────────────
                _buildAppBar(theme),

                // ── Step Indicator ───────────────────────────────────────────
                _buildStepIndicator(theme),

                // ── Content ──────────────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1Identitas(theme),
                      _buildStep2Pertanyaan(theme),
                      _buildStep3Summary(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    const titles = ['Identitas', 'Pertanyaan', 'Ringkasan'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CoreHeader(
        title: 'Input SPM — ${titles[_currentStep]}',
        subtitle: 'Langkah ${_currentStep + 1} dari ${titles.length}',
        onBackPressed: () {
          if (_currentStep > 0) {
            _goToStep(_currentStep - 1);
          } else {
            context.pop();
          }
        },
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    const labels = ['Identitas', 'Pertanyaan', 'Ringkasan'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDone || isActive
                              ? theme.primaryColor
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive ? theme.primaryColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < 2) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── STEP 1: Identitas ─────────────────────────────────────────────────────
  Widget _buildStep1Identitas(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih Identitas Pemeriksaan',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih koridor dan jenis objek yang akan diperiksa.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Koridor
          if (_isLoadingKoridor)
            const Center(child: CircularProgressIndicator())
          else
            CoreDropdownSearch<ReferenceDetail>(
              label: 'Koridor',
              hintText: 'Pilih koridor',
              popupTitle: 'Pilih Koridor',
              isRequired: true,
              items: _listKoridor,
              selectedItem: _selectedKoridor,
              itemAsString: (k) => k.name,
              compareFn: (a, b) => a.id == b.id,
              isItemSelected: (k) => k.id == _selectedKoridor?.id,
              onSelected: (k) {
                setState(() => _selectedKoridor = k);
                if (k != null) _loadTipePemeriksaan();
              },
            ),

          // Tipe Pemeriksaan
          if (_selectedKoridor != null) ...[
            const SizedBox(height: 20),
            if (_isLoadingTipe)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              CoreDropdownSearch<ReferenceDetail>(
                label: 'Tipe Pemeriksaan',
                hintText: 'Pilih tipe pemeriksaan',
                popupTitle: 'Pilih Tipe Pemeriksaan',
                isRequired: true,
                items: _listTipePemeriksaan,
                selectedItem: _selectedTipePemeriksaan,
                itemAsString: (t) => t.name,
                compareFn: (a, b) => a.id == b.id,
                isItemSelected: (t) => t.id == _selectedTipePemeriksaan?.id,
                onSelected: (t) {
                  setState(() {
                    _selectedTipePemeriksaan = t;
                    _selectedBus = null;
                    _selectedHalte = null;
                    _listBus = [];
                    _listHalte = [];
                  });
                  if (t?.code == 'BUS') {
                    _loadBus();
                  } else if (t?.code == 'HALTE') {
                    _loadHalte();
                  }
                },
              ),
          ],

          if (_selectedTipePemeriksaan != null) ...[
            if (_selectedTipePemeriksaan!.code == 'HALTE') ...[
              const SizedBox(height: 20),
              if (_isLoadingHalte)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                CoreDropdownSearch<ReferenceDetail>(
                  label: 'Halte',
                  hintText: 'Pilih halte',
                  popupTitle: 'Pilih Halte',
                  isRequired: true,
                  items: _listHalte,
                  selectedItem: _selectedHalte,
                  itemAsString: (t) => t.name,
                  compareFn: (a, b) => a.id == b.id,
                  isItemSelected: (t) => t.id == _selectedHalte?.id,
                  onSelected: (t) {
                    setState(() => _selectedHalte = t);
                  },
                ),
            ],

            if (_selectedTipePemeriksaan!.code == 'BUS') ...[
              const SizedBox(height: 20),
              if (_isLoadingBus)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                CoreDropdownSearch<ReferenceDetail>(
                  label: 'Bus',
                  hintText: 'Pilih bus',
                  popupTitle: 'Pilih Bus',
                  isRequired: true,
                  items: _listBus,
                  selectedItem: _selectedBus,
                  itemAsString: (t) => 'No. Lambung ${t.code} - ${t.name}',
                  compareFn: (a, b) => a.id == b.id,
                  isItemSelected: (t) => t.id == _selectedBus?.id,
                  onSelected: (t) {
                    setState(() => _selectedBus = t);
                  },
                ),
            ],
          ],

          SizedBox(height: 20),

          // Tombol Next
          BlocBuilder<SpmInputBloc, SpmInputState>(
            builder: (context, state) {
              final isLoading = state is QuestionsLoading;
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isIdentitasValid && !isLoading
                      ? _fetchPertanyaanAndGoNext
                      : null,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward, color: Colors.white),
                  label: Text(
                    isLoading ? 'Memuat...' : 'Lanjut ke Pertanyaan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    disabledBackgroundColor: theme.primaryColor.withValues(
                      alpha: 0.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── STEP 2: Pertanyaan ────────────────────────────────────────────────────
  Widget _buildStep2Pertanyaan(ThemeData theme) {
    if (_kategoriList.isEmpty || _pertanyaan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Belum ada pertanyaan untuk tipe ini.'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CoreButton(
                onPressed: () => _goToStep(0),
                text: 'Kembali',
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                size: CoreButtonSize.medium,
              ),
            ),
          ],
        ),
      );
    }

    final totalQuestions = _currentKategoriQuestions.length;
    final q = _currentQuestion;

    if (totalQuestions == 0 || q == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori: ${_kategoriList[_currentKategoriIndex]}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(
                child: Text('Belum ada pertanyaan untuk kategori ini.'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.navigate_next, color: Colors.white),
                label: const Text(
                  'Lanjut',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // final progress = (_currentQuestionIndex + 1) / totalQuestions;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori & Progress
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _kategoriList[_currentKategoriIndex],
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${_currentQuestionIndex + 1} / $totalQuestions',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(4),
          //   child: LinearProgressIndicator(
          //     value: progress,
          //     minHeight: 6,
          //     backgroundColor: Colors.grey.shade200,
          //     valueColor: AlwaysStoppedAnimation(theme.primaryColor),
          //   ),
          // ),
          const SizedBox(height: 28),

          // Pertanyaan
          Expanded(
            child: SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Pertanyaan ${_currentQuestionIndex + 1}',
                    //   style: theme.textTheme.bodySmall?.copyWith(
                    //     color: Colors.grey,
                    //   ),
                    // ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            q.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                        Text(
                          'Pertanyaan ${_currentQuestionIndex + 1}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      q.indikator,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    if (q.uraian.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          q.uraian,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Target: \n${q.nilai}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.scale, size: 16, color: Colors.orange),
                        const SizedBox(width: 6),
                        Text(
                          'Bobot Pertanyaan : ${q.bobotCapaian.toString()}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Input Nilai (0-100)
                    Text(
                      'Nilai Pencapaian',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Slider(
                            value:
                                double.tryParse(
                                  q.nilaiInput?.toString() ?? '0',
                                ) ??
                                0.0,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label:
                                (double.tryParse(
                                          q.nilaiInput?.toString() ?? '0',
                                        ) ??
                                        0.0)
                                    .toStringAsFixed(0),
                            onChanged: (v) => setState(() => q.nilaiInput = v),
                            activeColor: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 60,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.primaryColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            q.nilaiInput?.toString() ?? '0',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousQuestion,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.disabledColor, width: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Sebelumnya'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: q.nilai != '' ? _nextQuestion : null,
                  icon: Icon(
                    _currentQuestionIndex < _currentKategoriQuestions.length - 1
                        ? Icons.navigate_next
                        : _currentKategoriIndex < _kategoriList.length - 1
                        ? Icons.chevron_right
                        : Icons.check,
                    color: Colors.white,
                  ),
                  label: Text(
                    _currentQuestionIndex < _currentKategoriQuestions.length - 1
                        ? 'Selanjutnya'
                        : _currentKategoriIndex < _kategoriList.length - 1
                        ? 'Lanjut Kategori Berikut'
                        : 'Lihat Ringkasan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    disabledBackgroundColor: theme.primaryColor.withValues(
                      alpha: 0.4,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STEP 3: Summary ───────────────────────────────────────────────────────
  Widget _buildStep3Summary(ThemeData theme) {
    final grouped = <String, List<SpmQuestionModel>>{};
    for (final q in _pertanyaan) {
      grouped.putIfAbsent(q.categorySPM.name, () => []).add(q);
    }

    double totalNilai = 0;
    int totalJawab = 0;
    for (final q in _pertanyaan) {
      final parsedValue = q.nilaiInput;
      if (parsedValue != null) {
        totalNilai += parsedValue;
        totalJawab++;
      }
    }
    final rataRata = totalJawab > 0 ? totalNilai / totalJawab : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Penilaian',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tipe: ${_selectedTipePemeriksaan?.name ?? ''}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          if (_selectedBus != null)
            Text(
              'Bus: Nomor Lambung ${_selectedBus!.code} - ${_selectedBus!.name}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          if (_selectedHalte != null)
            Text(
              'Halte: ${_selectedHalte!.name}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          const SizedBox(height: 16),

          // Rata-rata keseluruhan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Nilai Rata-rata',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  rataRata.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Per kategori
          ...grouped.entries.map((entry) {
            final validQuestions = entry.value.where(
              (q) => q.nilaiInput != null,
            );
            final kategoriNilai = validQuestions.isEmpty
                ? 0.0
                : validQuestions.fold(0.0, (sum, q) => sum + q.nilaiInput!) /
                      validQuestions.length;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        kategoriNilai.isNaN
                            ? '-'
                            : kategoriNilai.toStringAsFixed(1),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  ...entry.value.map(
                    (q) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              q.name,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            q.nilaiInput?.toString() ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Tombol Simpan
          BlocBuilder<SpmInputBloc, SpmInputState>(
            builder: (context, state) {
              final isSubmitting =
                  state is SpmCreateLoading || state is SpmSubmitLoading;
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting ? null : _showSubmitDialog,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, color: Colors.white),
                  label: Text(
                    isSubmitting
                        ? (state is SpmSubmitLoading
                              ? 'Mensubmit...'
                              : 'Menyimpan...')
                        : 'Simpan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    disabledBackgroundColor: theme.primaryColor.withValues(
                      alpha: 0.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
