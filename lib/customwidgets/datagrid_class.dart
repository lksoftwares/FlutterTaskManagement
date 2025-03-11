import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ColumnConfig {
  final String columnName;
  final String labelText;
  final bool allowSorting;
  final bool allowFiltering;
  final bool visible;
  final bool allowEditing;
  final ColumnWidthMode columnWidthMode;
  ColumnConfig({
    required this.columnName,
    required this.labelText,
    this.allowSorting=false,
    this.allowFiltering =false,
    this.visible = false,
    this.allowEditing=false,
    this.columnWidthMode = ColumnWidthMode.fitByColumnName,
  });
}
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//
// enum ColumnDataType {
//   string,
//   int,
//   bool,
//   decimal,
//   float,
//   date,
// }
//
// class ColumnConfig {
//   final String columnName;
//   final String labelText;
//   final bool allowSorting;
//   final bool allowFiltering;
//   final bool visible;
//   final ColumnWidthMode columnWidthMode;
//   final ColumnDataType dataType;
//
//   ColumnConfig({
//     required this.columnName,
//     required this.labelText,
//     this.allowSorting = false,
//     this.allowFiltering = false,
//     this.visible = false,
//     this.columnWidthMode = ColumnWidthMode.fitByColumnName,
//     this.dataType = ColumnDataType.string,
//   });
// }
// class CustomDataGridSource extends DataGridSource {
//   final List<Map<String, dynamic>> data;
//   final List<ColumnConfig> columnConfigs;
//
//   CustomDataGridSource({required this.data, required this.columnConfigs});
//
//   @override
//   List<DataGridRow> get rows {
//     return data.map((rowData) {
//       return DataGridRow(cells: columnConfigs.map((config) {
//         var value = rowData[config.columnName];
//
//         switch (config.dataType) {
//           case ColumnDataType.int:
//             value = value != null ? int.tryParse(value.toString()) : null;
//             break;
//           case ColumnDataType.bool:
//             value = value != null ? (value.toString().toLowerCase() == 'true') : null;
//             break;
//           case ColumnDataType.float:
//             value = value != null ? double.tryParse(value.toString()) : null;
//             break;
//           case ColumnDataType.date:
//             value = value != null ? DateTime.tryParse(value.toString()) : null;
//             break;
//           default:
//           // Keep it as string by default
//             break;
//         }
//
//         return DataGridCell<String>(columnName: config.columnName, value: value);
//       }).toList());
//     }).toList();
//   }
//
//   @override
//   DataGridRowAdapter? buildRow(DataGridRow row) {
//     // TODO: implement buildRow
//     throw UnimplementedError();
//   }
// }
