import 'package:flutter/material.dart';
import 'package:txng/services/farm_management/care_history_service.dart';
import '../../../config/color_config.dart';
import './widgets.dart';

void showAccountDetails(
  BuildContext context,
  Map<String, dynamic> listCareHistory,
  String Function(String?) getProductName,
  String Function(String?) formatDate,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder:
        (context) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: const Text(
                  "Chi tiết lịch sử chăm sóc",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 22),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Đóng',
                  ),
                ],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                backgroundColor: Theme.of(context).colorScheme.surface,
                elevation: 0,
                shadowColor: Colors.black26,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDetailItem(
                      context,
                      "Hoạt động",
                      listCareHistory["tenhoatdong"]?.toString() ?? "Không có",
                      isTitle: true,
                      icon: Icons.task_alt,
                    ),
                    const SizedBox(height: 16),
                    buildDetailItem(
                      context,
                      "Sản phẩm sử dụng",
                      getProductName(
                        listCareHistory["sanphamsudung"]?.toString(),
                      ),
                      icon: Icons.science,
                    ),
                    buildDetailItem(
                      context,
                      "Nhà cung cấp",
                      listCareHistory["nhacungcap"]?["tencungcap"]
                              ?.toString() ??
                          "Không có",
                      icon: Icons.business,
                    ),
                    const SizedBox(height: 16),
                    buildDetailItem(
                      context,
                      "Ghi chú",
                      listCareHistory["ghichu"]?.toString() ?? "Không có",
                      isMultiline: true,
                      icon: Icons.note,
                    ),
                    const SizedBox(height: 16),
                    buildDetailItem(
                      context,
                      "Ngày tạo",
                      formatDate(listCareHistory["created_at"]?.toString()),
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 16),
                    buildDetailItem(
                      context,
                      "Ngày cập nhật",
                      formatDate(listCareHistory["updated_at"]?.toString()),
                      icon: Icons.update,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
  );
}

void showEditDialog(
  BuildContext context,
  Map<String, dynamic> listCareHistory,
  List<Map<String, dynamic>> listCareProcess,
  List<Map<String, dynamic>> listSupplier,
  List<Map<String, dynamic>> listFertilizerMedicine,
  CareHistoryService careHistoryService,
  Future<void> Function() loadCareHistoryes,
) {
  final TextEditingController hoatDongController = TextEditingController(
    text: listCareHistory['tenhoatdong']?.toString(),
  );
  final TextEditingController moTaController = TextEditingController(
    text: listCareHistory['ghichu']?.toString(),
  );
  final TextEditingController processController = TextEditingController(
    text:
        listCareProcess
            .firstWhere(
              (p) =>
                  p['id'].toString() ==
                  listCareHistory['maquytrinh']?.toString(),
              orElse: () => {'hoatdong': ''},
            )['hoatdong']
            ?.toString() ??
        '',
  );
  final TextEditingController supplierController = TextEditingController(
    text:
        listSupplier
            .firstWhere(
              (s) =>
                  s['id'].toString() ==
                  listCareHistory['manhacungcap']?.toString(),
              orElse: () => {'tennhacungcap': ''},
            )['tennhacungcap']
            ?.toString() ??
        '',
  );
  final TextEditingController fertilizerController = TextEditingController(
    text:
        listFertilizerMedicine
            .firstWhere(
              (f) => f['id'].toString() == listCareHistory['masp']?.toString(),
              orElse: () => {'tensanpham': ''},
            )['tensanpham']
            ?.toString() ??
        '',
  );
  String? selectedProcessId = listCareHistory['maquytrinh']?.toString();
  String? selectedSupplierId = listCareHistory['manhacungcap']?.toString();
  String? selectedFertilizerId = listCareHistory['masp']?.toString();
  bool processError = false;
  bool isLoading = false;

  showDialog(
    context: context,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    title: const Text("Chỉnh sửa lịch sử chăm sóc"),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return listCareProcess.map(
                                (item) =>
                                    item['hoatdong']?.toString() ??
                                    'Không có tên',
                              );
                            }
                            return listCareProcess
                                .map(
                                  (item) =>
                                      item['hoatdong']?.toString() ??
                                      'Không có tên',
                                )
                                .where(
                                  (option) => option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ),
                                );
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Quy trình chăm sóc*',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                prefixIcon: Icon(
                                  Icons.agriculture,
                                  color: ColorConfig.primary,
                                ),
                                errorText:
                                    processError
                                        ? 'Vui lòng nhập hoặc chọn quy trình chăm sóc 1'
                                        : null,
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                final process = listCareProcess.firstWhere(
                                  (p) =>
                                      p['hoatdong']?.toString().toLowerCase() ==
                                      value.toLowerCase(),
                                  orElse: () => {'id': null, 'hoatdong': value},
                                );
                                setState(() {
                                  selectedProcessId = process['id']?.toString();
                                  hoatDongController.text = value;
                                  processError = value.isEmpty;
                                });
                              },
                            );
                          },
                          initialValue: TextEditingValue(
                            text: processController.text,
                          ),
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(12),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    separatorBuilder:
                                        (_, __) => Divider(height: 1),
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return listSupplier.map(
                                (item) =>
                                    item['tennhacungcap']?.toString() ??
                                    'Không có tên',
                              );
                            }
                            return listSupplier
                                .map(
                                  (item) =>
                                      item['tennhacungcap']?.toString() ??
                                      'Không có tên',
                                )
                                .where(
                                  (option) => option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ),
                                );
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Nhà cung cấp',
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                prefixIcon: Icon(
                                  Icons.store,
                                  color: ColorConfig.primary,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                final supplier = listSupplier.firstWhere(
                                  (s) =>
                                      s['tennhacungcap']
                                          ?.toString()
                                          .toLowerCase() ==
                                      value.toLowerCase(),
                                  orElse:
                                      () => {
                                        'id': null,
                                        'tennhacungcap': value,
                                      },
                                );
                                setState(() {
                                  selectedSupplierId =
                                      supplier['id']?.toString();
                                });
                              },
                            );
                          },
                          initialValue: TextEditingValue(
                            text: supplierController.text,
                          ),
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(12),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    separatorBuilder:
                                        (_, __) => Divider(height: 1),
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return listFertilizerMedicine.map(
                                (item) =>
                                    item['tensanpham']?.toString() ??
                                    'Không có tên',
                              );
                            }
                            return listFertilizerMedicine
                                .map(
                                  (item) =>
                                      item['tensanpham']?.toString() ??
                                      'Không có tên',
                                )
                                .where(
                                  (option) => option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ),
                                );
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Sản phẩm sử dụng',
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                prefixIcon: Icon(
                                  Icons.science,
                                  color: ColorConfig.primary,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                final fertilizer = listFertilizerMedicine
                                    .firstWhere(
                                      (f) =>
                                          f['tensanpham']
                                              ?.toString()
                                              .toLowerCase() ==
                                          value.toLowerCase(),
                                      orElse:
                                          () => {
                                            'id': null,
                                            'tensanpham': value,
                                          },
                                    );
                                setState(() {
                                  selectedFertilizerId =
                                      fertilizer['id']?.toString();
                                });
                              },
                            );
                          },
                          initialValue: TextEditingValue(
                            text: fertilizerController.text,
                          ),
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(12),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    separatorBuilder:
                                        (_, __) => Divider(height: 1),
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: moTaController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Ghi chú',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).colorScheme.surfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text("Hủy"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // onPressed: () async {
                            //   if (processController.text.isEmpty) {
                            //     setState(() => processError = true);
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       const SnackBar(content: Text("Vui lòng nhập hoặc chọn quy trình chăm sóc")),
                            //     );
                            //     return;
                            //   }
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      if (hoatDongController.text.isEmpty) {
                                        // Thay processController bằng hoatDongController
                                        setState(() => processError = true);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              "Vui lòng nhập hoặc chọn quy trình chăm sóc 2",
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      setState(() => isLoading = true);
                                      try {
                                        final response =
                                            await careHistoryService
                                                .updateCareHistoryService(
                                                  listCareHistory["id"],
                                                  {
                                                    "quytrinh_id":
                                                        selectedProcessId,
                                                    "tenhoatdong":
                                                        hoatDongController.text,
                                                    "sanphamsudung":
                                                        selectedFertilizerId,
                                                    "ghichu":
                                                        moTaController.text,
                                                    "_method": "PUT",
                                                  },
                                                );

                                        if (response["status"] == true ||
                                            response["code"] == 200) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Cập nhật thành công!",
                                              ),
                                            ),
                                          );
                                          loadCareHistoryes();
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Cập nhật thất bại: ${response["message"] ?? "Lỗi không xác định"}",
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Lỗi khi cập nhật: $e",
                                            ),
                                          ),
                                        );
                                      } finally {
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                            child: const Text("Lưu"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
  );
}

void showAddDialog(
  BuildContext context,
  List<Map<String, dynamic>> listCareProcess,
  List<Map<String, dynamic>> listSupplier,
  List<Map<String, dynamic>> listFertilizerMedicine,
  CareHistoryService careHistoryService,
  Future<void> Function() loadCareHistoryes,
) {
  final TextEditingController hoatDongController = TextEditingController();
  final TextEditingController moTaController = TextEditingController();
  final TextEditingController processController = TextEditingController();
  final TextEditingController supplierController = TextEditingController();
  final TextEditingController fertilizerController = TextEditingController();
  String? selectedProcessId;
  String? selectedSupplierId;
  String? selectedFertilizerId;
  bool isLoading = false;
  bool processError = false;

  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder:
        (dialogContext) => StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    title: const Text(
                      "Thêm lịch sử mới",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.close, size: 24),
                        onPressed: () => Navigator.pop(dialogContext),
                        tooltip: 'Đóng',
                      ),
                    ],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    elevation: 0,
                    shadowColor: Colors.black26,
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return listCareProcess.map(
                                (item) =>
                                    item['hoatdong']?.toString() ??
                                    'Không có tên',
                              );
                            }
                            return listCareProcess
                                .map(
                                  (item) =>
                                      item['hoatdong']?.toString() ??
                                      'Không có tên',
                                )
                                .where(
                                  (option) => option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ),
                                );
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Quy trình chăm sóc',
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                prefixIcon: Icon(
                                  Icons.agriculture,
                                  color: Colors.black,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                errorText:
                                    processError
                                        ? 'Vui lòng nhập hoặc chọn quy trình chăm sóc 4'
                                        : null,
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                final process = listCareProcess.firstWhere(
                                  (p) =>
                                      p['hoatdong']?.toString().toLowerCase() ==
                                      value.toLowerCase(),
                                  orElse: () => {'id': null, 'hoatdong': value},
                                );
                                setState(() {
                                  selectedProcessId = process['id']?.toString();
                                  hoatDongController.text = value;
                                  processError = value.isEmpty;
                                });
                              },
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(12),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    separatorBuilder:
                                        (_, __) => Divider(height: 1),
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return listSupplier.map(
                                (item) =>
                                    item['tennhacungcap']?.toString() ??
                                    'Không có tên',
                              );
                            }
                            return listSupplier
                                .map(
                                  (item) =>
                                      item['tennhacungcap']?.toString() ??
                                      'Không có tên',
                                )
                                .where(
                                  (option) => option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ),
                                );
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Nhà cung cấp',
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                prefixIcon: Icon(
                                  Icons.store,
                                  color: ColorConfig.primary,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                final supplier = listSupplier.firstWhere(
                                  (s) =>
                                      s['tennhacungcap']
                                          ?.toString()
                                          .toLowerCase() ==
                                      value.toLowerCase(),
                                  orElse:
                                      () => {
                                        'id': null,
                                        'tennhacungcap': value,
                                      },
                                );
                                setState(() {
                                  selectedSupplierId =
                                      supplier['id']?.toString();
                                });
                              },
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(12),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    separatorBuilder:
                                        (_, __) => Divider(height: 1),
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return listFertilizerMedicine.map(
                                (item) =>
                                    item['tensanpham']?.toString() ??
                                    'Không có tên',
                              );
                            }
                            return listFertilizerMedicine
                                .map(
                                  (item) =>
                                      item['tensanpham']?.toString() ??
                                      'Không có tên',
                                )
                                .where(
                                  (option) => option.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ),
                                );
                          },
                          fieldViewBuilder: (
                            context,
                            controller,
                            focusNode,
                            onFieldSubmitted,
                          ) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Sản phẩm sử dụng',
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                prefixIcon: Icon(
                                  Icons.science,
                                  color: ColorConfig.primary,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) {
                                final fertilizer = listFertilizerMedicine
                                    .firstWhere(
                                      (f) =>
                                          f['tensanpham']
                                              ?.toString()
                                              .toLowerCase() ==
                                          value.toLowerCase(),
                                      orElse:
                                          () => {
                                            'id': null,
                                            'tensanpham': value,
                                          },
                                    );
                                setState(() {
                                  selectedFertilizerId =
                                      fertilizer['id']?.toString();
                                });
                              },
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(12),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                  ),
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    separatorBuilder:
                                        (_, __) => Divider(height: 1),
                                    itemBuilder: (
                                      BuildContext context,
                                      int index,
                                    ) {
                                      final option = options.elementAt(index);
                                      return ListTile(
                                        title: Text(option),
                                        onTap: () => onSelected(option),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: moTaController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Mô tả',
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(
                              color: ColorConfig.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                              ),
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).colorScheme.surfaceVariant,
                            prefixIcon: Icon(
                              Icons.description,
                              color: ColorConfig.primary,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  bottomNavigationBar: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              foregroundColor:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text(
                              "Hủy",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor:
                                  ColorConfig.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              elevation: 2,
                            ),
                            onPressed:
                                isLoading
                                    ? null
                                    : () async {
                                      if (processController.text.isEmpty) {
                                        setState(() => processError = true);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              "Vui lòng nhập hoặc chọn quy trình chăm sóc 5",
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() => isLoading = true);
                                      try {
                                        final response =
                                            await careHistoryService
                                                .createCareHistoryService({
                                                  "quytrinh_id":
                                                      selectedProcessId,
                                                  "tenhoatdong":
                                                      hoatDongController.text,
                                                  "sanphamsudung":
                                                      selectedFertilizerId,
                                                  "ghichu": moTaController.text,
                                                });

                                        if (response["status"] == true ||
                                            response["code"] == 200) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                "Thêm mới thành công!",
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                          loadCareHistoryes();
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Thêm mới thất bại: ${response["message"] ?? "Lỗi không xác định"}",
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Lỗi khi thêm mới: $e",
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                      } finally {
                                        setState(() => isLoading = false);
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                            child:
                                isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Text(
                                      "Thêm",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
  );
}

void confirmDelete(
  BuildContext context,
  Map<String, dynamic> listCareHistory,
  CareHistoryService careHistoryService,
  Future<void> Function() loadCareHistoryes,
) {
  showDialog(
    context: context,
    builder:
        (dialogContext) => Dialog(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: const Text("Xác nhận xóa"),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Bạn có chắc chắn muốn xóa lịch sử chăm sóc '${listCareHistory["tenhoatdong"]}' không?",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Hủy"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            foregroundColor:
                                Theme.of(context).colorScheme.onError,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(dialogContext);
                            try {
                              final response = await careHistoryService
                                  .deleteCareHistoryService(
                                    listCareHistory["id"],
                                    {"_method": "DELETE"},
                                  );
                              if (response["status"] == true ||
                                  response["code"] == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Xóa lịch sử thành công."),
                                  ),
                                );
                                loadCareHistoryes();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Xóa thất bại: ${response["message"] ?? "Lỗi không xác định"}",
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Lỗi khi xóa lịch sử: $e"),
                                ),
                              );
                            }
                          },
                          child: const Text("Xóa"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}
