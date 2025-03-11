//
// import 'package:flutter/cupertino.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//
// List<GridColumn> buildDataGridColumns(List<Map<String, dynamic>> columnsConfig) {
//   List<GridColumn> columns = [];
//
//   for (var config in columnsConfig) {
//     final columnName = config['columnName'];
//     final labelText = config['labelText'];
//
//     columns.add(
//       GridColumn(
//         columnName: columnName,
//         allowSorting: true,
//         allowFiltering: true,
//         label: Container(
//           alignment: Alignment.center,
//           padding: EdgeInsets.all(8.0),
//           child: Text(labelText),
//         ),
//       ),
//     );
//     columns.add(
//       GridColumn(
//         columnName: columnName,
//         allowSorting: true,
//         allowFiltering: true,
//         label: Container(
//           alignment: Alignment.center,
//           padding: EdgeInsets.all(8.0),
//           child: Text(labelText),
//         ),
//       ),
//     );
//     columns.add(GridColumn(
//       columnName: 'edit_$columnName',
//       allowSorting: false,
//       allowFiltering: false,
//       label: Container(
//         alignment: Alignment.center,
//         padding: EdgeInsets.all(8.0),
//         child: Text('Edit'),
//       ),
//     ));
//
//     columns.add(GridColumn(
//       columnName: 'delete_$columnName',
//       allowSorting: false,
//       allowFiltering: false,
//       label: Container(
//         alignment: Alignment.center,
//         padding: EdgeInsets.all(8.0),
//         child: Text('Delete'),
//       ),
//     ));
//     columns.add(GridColumn(
//       columnName: 'delete_$columnName',
//       allowSorting: false,
//       allowFiltering: false,
//       label: Container(
//         alignment: Alignment.center,
//         padding: EdgeInsets.all(8.0),
//         child: Text('Delete'),
//       ),
//     ));
//   }
//   return columns;
// }
// import 'package:flutter/cupertino.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
// import 'datagrid_class.dart';
//
// List<GridColumn> buildDataGridColumns(List<ColumnConfig> columnsConfig) {
//   List<GridColumn> columns = [];
//
//   for (var config in columnsConfig) {
//     columns.add(
//       GridColumn(
//         columnName: config.columnName,
//         allowSorting: config.allowSorting,
//         allowFiltering: config.allowFiltering,
//         columnWidthMode: config.columnWidthMode,
//         allowEditing: config.allowEditing,
//         visible: config.visible,
//         label: Container(
//           alignment: Alignment.center,
//           padding: EdgeInsets.all(8.0),
//           child: Text(config.labelText),
//         ),
//       ),
//     );
//   }
//
//   // columns.add(GridColumn(
//   //   columnName: 'checkbox',
//   //   visible: false,
//   //   allowSorting: false,
//   //   allowFiltering: false,
//   //   label: Container(
//   //     alignment: Alignment.center,
//   //     padding: EdgeInsets.all(8.0),
//   //     child: Text('Select'),
//   //   ),
//   // ));
//
//     columns.add(GridColumn(
//     columnName: 'edit',
//     allowSorting: false,
//     allowFiltering: false,
//     label: Container(
//       alignment: Alignment.center,
//       padding: EdgeInsets.all(8.0),
//       child: Text('Edit'),
//     ),
//   ));
//
//   columns.add(GridColumn(
//     columnName: 'delete',
//     allowSorting: false,
//     allowFiltering: false,
//     label: Container(
//       alignment: Alignment.center,
//       padding: EdgeInsets.all(8.0),
//       child: Text('Delete'),
//     ),
//   ));
//
//   return columns;
// }
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'datagrid_class.dart';

List<GridColumn> buildDataGridColumns(List<ColumnConfig> columnsConfig, {bool showEditColumn = false, bool showDeleteColumn = false}) {
  List<GridColumn> columns = [];

  for (var config in columnsConfig) {
    columns.add(
      GridColumn(
        columnName: config.columnName,
        allowSorting: config.allowSorting,
        allowFiltering: config.allowFiltering,
        columnWidthMode: config.columnWidthMode,
        allowEditing: config.allowEditing,
        visible: config.visible,
        label: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(config.labelText),
        ),
      ),
    );
  }

  // Add the Edit column with visibility based on the parameter
  columns.add(GridColumn(
    columnName: 'edit',
    allowSorting: false,
    allowFiltering: false,
    visible: showEditColumn, // Set visibility based on the parameter
    label: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(8.0),
      child: Text('Edit'),
    ),
  ));

  columns.add(GridColumn(
    columnName: 'delete',
    allowSorting: false,
    allowFiltering: false,
    visible: showDeleteColumn,
    label: Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(8.0),
      child: Text('Delete'),
    ),
  ));

  return columns;
}
