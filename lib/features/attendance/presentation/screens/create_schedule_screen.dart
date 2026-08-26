import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travis/core/network/dio_client.dart';
import 'package:travis/core/presentations/widgets/widgets.dart';
import 'package:travis/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:travis/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:travis/features/reference/domain/entities/reference_detail.dart';
import 'package:travis/features/reference/reference_data_source.dart';

class CreateScheduleScreen extends StatefulWidget {
  const CreateScheduleScreen({super.key});

  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  final ReferenceDataSource _refDs = ReferenceDataSource(
    dio: DioClient().instance,
  );
  late final AttendanceRepositoryImpl _repo;

  bool _isLoading = false;

  ReferenceDetail? _selectedBulan;
  ReferenceDetail? _selectedKoridor;
  ReferenceDetail? _selectedTypeJadwal;

  List<ReferenceDetail> _selectedKorlap = [];
  List<ReferenceDetail> _selectedPramugara = [];
  List<ReferenceDetail> _selectedCadangan = [];
  List<ReferenceDetail> _selectedBus = [];

  List<ReferenceDetail> _listBulan = [];
  List<ReferenceDetail> _listKoridor = [];
  List<ReferenceDetail> _listTypeJadwal = [];

  bool _isInitLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = AttendanceRepositoryImpl(
      remoteDataSource: AttendanceRemoteDataSourceImpl(DioClient()),
    );
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final bulan = await _refDs.fetchReferenceBulan('');
      final koridor = await _refDs.fetchReferenceKoridor('');
      final typeJadwal = await _refDs.fetchReferenceTypeJadwal('');

      setState(() {
        _listBulan = bulan;
        _listKoridor = koridor;
        _listTypeJadwal = typeJadwal;
        _isInitLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isInitLoading = false);
        showCoreErrorDialog(context, 'Error', 'Gagal memuat data referensi');
      }
    }
  }

  Future<List<ReferenceDetail>> _fetchKorlap(String q) {
    if (_selectedKoridor == null) return Future.value([]);
    return _refDs.fetchReferenceDataKorlap(q, _selectedKoridor!.id);
  }

  Future<List<ReferenceDetail>> _fetchPramugara(String q) {
    if (_selectedKoridor == null) return Future.value([]);
    return _refDs.fetchReferenceDataPramugara(q, _selectedKoridor!.id);
  }

  Future<List<ReferenceDetail>> _fetchCadangan(String q) {
    if (_selectedKoridor == null) return Future.value([]);
    final selectedPramugaraIds = _selectedPramugara.map((e) => e.id).toList();
    return _refDs.fetchReferenceDataPramugaraCadangan(
      q,
      _selectedKoridor!.id,
      selectedPramugaraIds,
    );
  }

  Future<List<ReferenceDetail>> _fetchBus(String q) {
    if (_selectedKoridor == null) return Future.value([]);
    return _refDs.fetchReferenceBus(q, _selectedKoridor!.id);
  }

  Future<void> _submit() async {
    if (_selectedBulan == null ||
        _selectedKoridor == null ||
        _selectedTypeJadwal == null) {
      showCoreErrorDialog(
        context,
        'Validasi',
        'Lengkapi kolom yang wajib diisi (Bulan, Koridor, Type Jadwal)',
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await _repo.createSchedule(
        bulan: _selectedBulan!.code,
        koridor: _selectedKoridor!.id,
        typeJadwal: _selectedTypeJadwal!.code,
        idKorlap: _selectedKorlap.map((e) => e.id).toList(),
        idPramugara: _selectedPramugara.map((e) => e.id).toList(),
        idCadangan: _selectedCadangan.map((e) => e.id).toList(),
        idBus: _selectedBus.map((e) => e.id).toList(),
      );

      if (success && mounted) {
        showCoreSuccessDialog(
          context,
          'Sukses',
          'Jadwal berhasil dibuat',
        ).then((_) {
          if (mounted) context.pop(true);
        });
      }
    } catch (e) {
      if (mounted) {
        showCoreErrorDialog(
          context,
          'Gagal',
          e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openMultiSelect(
    String title,
    List<ReferenceDetail> selectedItems,
    Future<List<ReferenceDetail>> Function(String) fetchFn,
    ValueChanged<List<ReferenceDetail>> onSave,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MultiSelectSheet(
        title: title,
        initialSelected: selectedItems,
        fetchFn: fetchFn,
        onSave: onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isInitLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CoreHeader(
              title: 'Buat Jadwal',
              subtitle: 'Form pengisian jadwal baru',
              showBackButton: true,
              onBackPressed: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CoreDropdownSearch<ReferenceDetail>(
                      label: 'Bulan',
                      hintText: 'Pilih bulan',
                      popupTitle: 'Pilih Bulan',
                      isRequired: true,
                      items: _listBulan,
                      itemAsString: (i) => i.name,
                      compareFn: (a, b) => a.id == b.id,
                      selectedItem: _selectedBulan,
                      onSelected: (v) => setState(() => _selectedBulan = v),
                    ),
                    const SizedBox(height: 16),
                    CoreDropdownSearch<ReferenceDetail>(
                      label: 'Koridor',
                      hintText: 'Pilih koridor',
                      popupTitle: 'Pilih Koridor',
                      isRequired: true,
                      items: _listKoridor,
                      itemAsString: (i) => i.name,
                      compareFn: (a, b) => a.id == b.id,
                      selectedItem: _selectedKoridor,
                      onSelected: (v) {
                        setState(() {
                          _selectedKoridor = v;
                          _selectedBus.clear();
                          _selectedKorlap.clear();
                          _selectedPramugara.clear();
                          _selectedCadangan.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    CoreDropdownSearch<ReferenceDetail>(
                      label: 'Type Jadwal',
                      hintText: 'Pilih type jadwal',
                      popupTitle: 'Pilih Type Jadwal',
                      isRequired: true,
                      items: _listTypeJadwal,
                      itemAsString: (i) => i.name,
                      compareFn: (a, b) => a.id == b.id,
                      selectedItem: _selectedTypeJadwal,
                      onSelected: (v) =>
                          setState(() => _selectedTypeJadwal = v),
                    ),
                    const SizedBox(height: 16),

                    // Checkboxes / Multi Selects
                    if (_selectedTypeJadwal != null) ...[
                      _buildMultiSelectField(
                        label: 'Data Korlap',
                        selectedItems: _selectedKorlap,
                        fetchFn: _fetchKorlap,
                        onSave: (v) => setState(() => _selectedKorlap = v),
                        isDisabled: _selectedKoridor == null,
                        disabledMessage: 'Pilih koridor terlebih dahulu',
                      ),
                    ],
                    if (_selectedKorlap.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildMultiSelectField(
                        label: 'Data Pramugara',
                        selectedItems: _selectedPramugara,
                        fetchFn: _fetchPramugara,
                        onSave: (v) => setState(() {
                          _selectedPramugara = v;
                          _selectedCadangan.clear();
                        }),
                        isDisabled: _selectedKoridor == null,
                        disabledMessage: 'Pilih koridor terlebih dahulu',
                      ),
                    ],
                    if (_selectedPramugara.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildMultiSelectField(
                        label: 'Pramugara Cadangan',
                        selectedItems: _selectedCadangan,
                        fetchFn: _fetchCadangan,
                        onSave: (v) => setState(() => _selectedCadangan = v),
                        isDisabled: _selectedKoridor == null,
                        disabledMessage: 'Pilih koridor terlebih dahulu',
                      ),
                    ],
                    if (_selectedCadangan.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildMultiSelectField(
                        label: 'Bus',
                        selectedItems: _selectedBus,
                        fetchFn: _fetchBus,
                        onSave: (v) => setState(() => _selectedBus = v),
                        isDisabled: _selectedKoridor == null,
                        disabledMessage: 'Pilih koridor terlebih dahulu',
                      ),
                    ],
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          disabledBackgroundColor: theme.primaryColor
                              .withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Simpan Jadwal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<ReferenceDetail> selectedItems,
    required Future<List<ReferenceDetail>> Function(String) fetchFn,
    required ValueChanged<List<ReferenceDetail>> onSave,
    bool isDisabled = false,
    String? disabledMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isDisabled
              ? () => showCoreErrorDialog(
                  context,
                  'Perhatian',
                  disabledMessage ?? '',
                )
              : () => _openMultiSelect(label, selectedItems, fetchFn, onSave),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDisabled
                  ? Colors.grey.withValues(alpha: 0.12)
                  : Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300, width: 1.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItems.isEmpty
                        ? 'Pilih $label'
                        : '${selectedItems.length} terpilih',
                    style: TextStyle(
                      color: selectedItems.isEmpty
                          ? Colors.grey.shade500
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MultiSelectSheet extends StatefulWidget {
  final String title;
  final List<ReferenceDetail> initialSelected;
  final Future<List<ReferenceDetail>> Function(String) fetchFn;
  final ValueChanged<List<ReferenceDetail>> onSave;

  const _MultiSelectSheet({
    required this.title,
    required this.initialSelected,
    required this.fetchFn,
    required this.onSave,
  });

  @override
  State<_MultiSelectSheet> createState() => _MultiSelectSheetState();
}

class _MultiSelectSheetState extends State<_MultiSelectSheet> {
  List<ReferenceDetail> _items = [];
  List<ReferenceDetail> _selectedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.initialSelected);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final res = await widget.fetchFn('');
      if (mounted) {
        setState(() {
          _items = res;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final isSelected = _selectedItems.any(
                          (e) => e.id == item.id,
                        );
                        return CheckboxListTile(
                          title: Text(item.name),
                          value: isSelected,
                          activeColor: theme.primaryColor,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedItems.add(item);
                              } else {
                                _selectedItems.removeWhere(
                                  (e) => e.id == item.id,
                                );
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(_selectedItems);
                    context.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
