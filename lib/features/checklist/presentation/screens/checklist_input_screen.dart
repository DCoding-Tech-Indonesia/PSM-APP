import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:psm_mobile/core/network/dio_client.dart';
import 'package:psm_mobile/core/notification/approval_refresh_notifier.dart';
import 'package:psm_mobile/core/presentations/widgets/core_dropdown_search.dart';
import 'package:psm_mobile/core/presentations/widgets/core_header.dart';
import 'package:psm_mobile/features/checklist/data/models/checklist_question_model.dart';
import 'package:psm_mobile/features/checklist/presentation/bloc/checklist_input/checklist_input_bloc.dart';
import 'package:psm_mobile/features/checklist/presentation/bloc/checklist_input/checklist_input_event.dart';
import 'package:psm_mobile/features/checklist/presentation/bloc/checklist_input/checklist_input_state.dart';
import 'package:psm_mobile/features/reference/domain/entities/reference_detail.dart';
import 'package:psm_mobile/features/reference/reference_data_source.dart';

import 'package:intl/intl.dart';
import 'package:psm_mobile/core/presentations/widgets/core_blur_dialog.dart';

import 'package:psm_mobile/features/checklist/data/datasources/checklist_remote_data_source.dart';
import 'package:psm_mobile/features/checklist/data/repositories/checklist_repository_impl.dart';

class ChecklistInputScreen extends StatelessWidget {
  const ChecklistInputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChecklistInputBloc(
        repository: ChecklistRepositoryImpl(
          remoteDataSource: ChecklistRemoteDataSource(
            dio: DioClient().instance,
          ),
        ),
      ),
      child: const _ChecklistInputScreenView(),
    );
  }
}

class _ChecklistInputScreenView extends StatefulWidget {
  const _ChecklistInputScreenView();

  @override
  State<_ChecklistInputScreenView> createState() =>
      _ChecklistInputScreenViewState();
}

class _ChecklistInputScreenViewState extends State<_ChecklistInputScreenView> {
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0: Identitas, 1: Pertanyaan, 2: Summary

  late final ReferenceDataSource _referenceDataSource;

  // ── Step 1: Identitas ─────────────────────────────────────────────────────
  ReferenceDetail? _selectedKoridor;
  ReferenceDetail? _selectedBus;
  ReferenceDetail? _selectedPramugara;
  ReferenceDetail? _selectedShift;
  ReferenceDetail? _selectedTipeForm;

  bool _isLoadingKoridor = false;
  bool _isLoadingBus = false;
  bool _isLoadingPramugara = false;
  bool _isLoadingShift = false;
  bool _isLoadingTipeForm = false;

  List<ReferenceDetail> _listKoridor = [];
  List<ReferenceDetail> _listBus = [];
  List<ReferenceDetail> _listPramugara = [];
  List<ReferenceDetail> _listShift = [];
  List<ReferenceDetail> _listTipeForm = [];

  bool get _isIdentitasValid {
    return _selectedKoridor != null &&
        _selectedBus != null &&
        _selectedPramugara != null &&
        _selectedShift != null &&
        _selectedTipeForm != null;
  }

  // ── Step 2: Pertanyaan ────────────────────────────────────────────────────
  List<ChecklistQuestionModel> _pertanyaan = [];
  int _currentQuestionIndex = 0;

  ChecklistQuestionModel? get _currentQuestion {
    if (_pertanyaan.isEmpty || _currentQuestionIndex >= _pertanyaan.length) {
      return null;
    }
    return _pertanyaan[_currentQuestionIndex];
  }

  @override
  void initState() {
    super.initState();
    _referenceDataSource = ReferenceDataSource(dio: DioClient().instance);
    _loadInitialData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Data Loaders ────────────────────────────────────────────────────────
  Future<void> _loadInitialData() async {
    _loadKoridor();
  }

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

  Future<void> _loadPramugara() async {
    setState(() => _isLoadingPramugara = true);
    try {
      final result = await _referenceDataSource.fetchReferencePramugara('');
      if (mounted) {
        setState(() {
          _listPramugara = result;
          _isLoadingPramugara = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPramugara = false);
    }
  }

  Future<void> _loadShift() async {
    setState(() => _isLoadingShift = true);
    try {
      final result = await _referenceDataSource.fetchReferenceShiftKaryawan('');
      if (mounted) {
        setState(() {
          _listShift = result;
          _isLoadingShift = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingShift = false);
    }
  }

  Future<void> _loadTipeForm() async {
    setState(() => _isLoadingTipeForm = true);
    try {
      final result = await _referenceDataSource.fetchReferenceTypeChecklist('');
      if (mounted) {
        setState(() {
          _listTipeForm = result;
          _isLoadingTipeForm = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingTipeForm = false);
    }
  }

  void _fetchPertanyaanAndGoNext() {
    context.read<ChecklistInputBloc>().add(
      LoadChecklistQuestions(_selectedTipeForm!.code),
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
    if (_currentQuestionIndex < _pertanyaan.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _goToStep(2);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() => _currentQuestionIndex--);
    } else {
      _goToStep(0);
    }
  }

  void _showSubmitDialog() {
    showCoreConfirmDialog(
      context: context,
      title: 'Simpan Checklist',
      message: 'Apakah Anda yakin ingin menyimpan data checklist harian ini?',
      onConfirm: _submitData,
    );
  }

  void _submitData() {
    final payload = {
      "idKoridor": _selectedKoridor?.id,
      "idBus": _selectedBus?.id,
      "idPramugara": _selectedPramugara?.id,
      "idShift": _selectedShift?.id,
      "tipeForm": _selectedTipeForm?.id,
      "tanggal": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      "detail": _pertanyaan
          .map(
            (q) => {
              "uraian": q.uraian,
              "kondisi": q.value ?? false,
              "keterangan": q.notes ?? "",
            },
          )
          .toList(),
    };

    context.read<ChecklistInputBloc>().add(SubmitChecklist(payload));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ChecklistInputBloc, ChecklistInputState>(
      listener: (context, state) {
        if (kDebugMode) {
          print('state: $state');
        }
        if (state is ChecklistQuestionsLoaded) {
          setState(() {
            _pertanyaan = state.questions;
            _currentQuestionIndex = 0;
          });
          _goToStep(1);
        } else if (state is ChecklistQuestionsError) {
          showCoreErrorDialog(
            context,
            'Error',
            'Gagal memuat pertanyaan. Error: ${state.message}',
          );
        } else if (state is ChecklistSubmitting) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state is ChecklistSubmitSuccess) {
          // 1. WAJIB: Tutup dialog loading (CircularProgressIndicator) terlebih dahulu
          Navigator.of(context, rootNavigator: true).pop();

          // 2. Kunci router halaman utama sebelum membuka dialog baru
          final router = GoRouter.of(context);

          // 3. Tampilkan pesan sukses dinamis dari response API
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
        } else if (state is ChecklistSubmitError) {
          // Tutup dialog loading jika gagal
          Navigator.of(context, rootNavigator: true).pop();

          // Tampilkan pesan error dinamis dari response API
          showCoreErrorDialog(context, 'Gagal Menyimpan', state.message);
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
        title: 'Input Checklist — ${titles[_currentStep]}',
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
            'Identitas Checklist',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pilih kelengkapan data operasional yang akan diisi.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Koridor
          if (_isLoadingKoridor)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ),
            )
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
                setState(() {
                  _selectedKoridor = k;
                  _selectedBus = null;
                  _listBus = [];
                });
                if (k != null) _loadBus();
              },
            ),

          // Bus
          if (_selectedKoridor != null) ...[
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
                  setState(() {
                    _selectedBus = t;
                    _selectedPramugara = null;
                    _selectedShift = null;
                    _selectedTipeForm = null;
                    _listPramugara = [];
                    _listShift = [];
                    _listTipeForm = [];
                  });
                  if (t != null) _loadPramugara();
                },
              ),
          ],

          // Pramugara
          if (_selectedBus != null) ...[
            const SizedBox(height: 20),
            if (_isLoadingPramugara)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              CoreDropdownSearch<ReferenceDetail>(
                label: 'Pramugara',
                hintText: 'Pilih pramugara',
                popupTitle: 'Pilih Pramugara',
                isRequired: true,
                items: _listPramugara,
                selectedItem: _selectedPramugara,
                itemAsString: (t) => t.name,
                compareFn: (a, b) => a.id == b.id,
                isItemSelected: (t) => t.id == _selectedPramugara?.id,
                onSelected: (t) {
                  setState(() {
                    _selectedPramugara = t;
                    _selectedShift = null;
                    _selectedTipeForm = null;
                    _listShift = [];
                    _listTipeForm = [];
                  });
                  if (t != null) _loadShift();
                },
              ),
          ],

          // Shift
          if (_selectedPramugara != null) ...[
            const SizedBox(height: 20),
            if (_isLoadingShift)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              CoreDropdownSearch<ReferenceDetail>(
                label: 'Shift',
                hintText: 'Pilih shift',
                popupTitle: 'Pilih Shift',
                isRequired: true,
                items: _listShift,
                selectedItem: _selectedShift,
                itemAsString: (t) => t.name,
                compareFn: (a, b) => a.id == b.id,
                isItemSelected: (t) => t.id == _selectedShift?.id,
                onSelected: (t) {
                  setState(() {
                    _selectedShift = t;
                    _selectedTipeForm = null;
                    _listTipeForm = [];
                  });
                  if (t != null) _loadTipeForm();
                },
              ),
          ],

          // Tipe Form
          if (_selectedShift != null) ...[
            const SizedBox(height: 20),
            if (_isLoadingTipeForm)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              CoreDropdownSearch<ReferenceDetail>(
                label: 'Tipe Form',
                hintText: 'Pilih tipe form',
                popupTitle: 'Pilih Tipe Form',
                isRequired: true,
                items: _listTipeForm,
                selectedItem: _selectedTipeForm,
                itemAsString: (t) => t.name,
                compareFn: (a, b) => a.id == b.id,
                isItemSelected: (t) => t.id == _selectedTipeForm?.id,
                onSelected: (t) {
                  setState(() => _selectedTipeForm = t);
                },
              ),
          ],

          const SizedBox(height: 32),

          // Tombol Next
          BlocBuilder<ChecklistInputBloc, ChecklistInputState>(
            builder: (context, state) {
              final isLoading = state is ChecklistQuestionsLoading;
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
    if (_pertanyaan.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Belum ada pertanyaan untuk tipe ini.'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () => _goToStep(0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      );
    }

    final q = _currentQuestion;
    if (q == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pertanyaan ${_currentQuestionIndex + 1} dari ${_pertanyaan.length}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (q.grup != null)
                  Text(
                    q.grup.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  q.uraian,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (q.sanksi != null && q.sanksi!.isNotEmpty)
                  Text(
                    'Sanksi : \n${q.sanksi}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 24),

                // Yes/No Options
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _pertanyaan[_currentQuestionIndex] = q.copyWith(
                              value: true,
                            );
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: q.value == true
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: q.value == true
                                  ? Colors.green
                                  : Colors.grey.withValues(alpha: 0.3),
                              width: q.value == true ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: q.value == true
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Sesuai',
                                style: TextStyle(
                                  fontWeight: q.value == true
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: q.value == true ? Colors.green : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _pertanyaan[_currentQuestionIndex] = q.copyWith(
                              value: false,
                            );
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: q.value == false
                                ? Colors.red.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: q.value == false
                                  ? Colors.red
                                  : Colors.grey.withValues(alpha: 0.3),
                              width: q.value == false ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel,
                                color: q.value == false
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tidak Sesuai',
                                style: TextStyle(
                                  fontWeight: q.value == false
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: q.value == false ? Colors.red : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // Keterangan / Notes
                TextFormField(
                  key: ValueKey('notes_${q.id}'),
                  initialValue: q.notes,
                  onChanged: (val) {
                    setState(() {
                      _pertanyaan[_currentQuestionIndex] = q.copyWith(
                        notes: val,
                      );
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Keterangan Wajib Diisi',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: (q.notes == null || q.notes!.trim().isEmpty)
                            ? Colors.red.withValues(alpha: 0.5)
                            : theme.disabledColor.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: (q.notes == null || q.notes!.trim().isEmpty)
                            ? Colors.red
                            : theme.primaryColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

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
                child: Builder(
                  builder: (context) {
                    bool isValid =
                        q.value != null &&
                        (q.notes != null && q.notes!.trim().isNotEmpty);

                    return ElevatedButton(
                      onPressed: isValid ? _nextQuestion : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        disabledBackgroundColor: theme.primaryColor.withValues(
                          alpha: 0.4,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _currentQuestionIndex < _pertanyaan.length - 1
                            ? 'Selanjutnya'
                            : 'Selesai & Lanjut',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
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
    int totalSesuai = _pertanyaan.where((q) => q.value == true).length;
    int totalTidakSesuai = _pertanyaan.where((q) => q.value == false).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fact_check_outlined,
                size: 48,
                color: theme.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Ringkasan Checklist',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Periksa kembali data yang telah Anda isi sebelum disimpan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),

          // Card Identitas
          Text(
            'Informasi Identitas',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow(
                  Icons.route,
                  'Koridor',
                  _selectedKoridor?.name ?? '-',
                ),
                const Divider(height: 16, color: Colors.transparent),
                _buildSummaryRow(
                  Icons.directions_bus,
                  'Bus',
                  _selectedBus != null
                      ? 'No. Lambung ${_selectedBus!.code} - ${_selectedBus!.name}'
                      : '-',
                ),
                const Divider(height: 16, color: Colors.transparent),
                _buildSummaryRow(
                  Icons.person,
                  'Pramugara',
                  _selectedPramugara?.name ?? '-',
                ),
                const Divider(height: 16, color: Colors.transparent),
                _buildSummaryRow(
                  Icons.schedule,
                  'Shift',
                  _selectedShift?.name ?? '-',
                ),
                const Divider(height: 16, color: Colors.transparent),
                _buildSummaryRow(
                  Icons.assignment,
                  'Tipe Form',
                  _selectedTipeForm?.name ?? '-',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Summary Stats
          Text(
            'Hasil Pemeriksaan',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$totalSesuai',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sesuai',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$totalTidakSesuai',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tidak Sesuai',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Submit Action
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _goToStep(1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.disabledColor, width: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _showSubmitDialog,
                  icon: const Icon(Icons.save, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  label: const Text(
                    'Simpan Data',
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
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        const Text(': ', style: TextStyle(color: Colors.grey)),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
