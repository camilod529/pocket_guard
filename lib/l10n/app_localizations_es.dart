// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get accountCurrency => 'Moneda';

  @override
  String get accountCurrencyHint => 'USD, EUR, GBP';

  @override
  String get accountDeletedSuccessfully => 'Cuenta eliminada con éxito';

  @override
  String accountLabel(String name) {
    return 'Cuenta';
  }

  @override
  String get accountName => 'Nombre de Cuenta';

  @override
  String get accountNameHint => 'Ingrese nombre de cuenta';

  @override
  String get accounts => 'Cuentas';

  @override
  String get accountTypeAsset => 'Activo';

  @override
  String get accountTypeCash => 'Efectivo';

  @override
  String get accountTypeCredit => 'Crédito';

  @override
  String get accountTypeLabel => 'Tipo de Cuenta';

  @override
  String get addAccount => 'Agregar Cuenta';

  @override
  String get amountHint => '0.00';

  @override
  String get amountLabel => 'Monto';

  @override
  String get appTitle => 'Administrador de Dinero';

  @override
  String get blue => 'Azul';

  @override
  String get calendar => 'Calendario';

  @override
  String get calendarGoToToday => 'Ir a hoy';

  @override
  String get calendarNextMonth => 'Mes siguiente';

  @override
  String get calendarPreviousMonth => 'Mes anterior';

  @override
  String get cancel => 'Cancelar';

  @override
  String get categories => 'Categorías';

  @override
  String get category_expense_food_dining => 'Comida';

  @override
  String get category_expense_rent => 'Alquiler';

  @override
  String get category_expense_transportation => 'Transporte';

  @override
  String get category_income_freelance => 'Freelance';

  @override
  String get category_income_salary => 'Salario';

  @override
  String get category_transfer => 'Transferencia';

  @override
  String get categoryDeletedSuccessfully => 'Categoría eliminada con éxito';

  @override
  String categoryDeleteError(String error) {
    return 'Error al eliminar la categoría: $error';
  }

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get categoryName => 'Nombre de Categoría';

  @override
  String get chooseYourAppColor => 'Elige el color de tu aplicación';

  @override
  String get create => 'Crear';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get createCategory => 'Crear Categoría';

  @override
  String get createTransaction => 'Crear Transacción';

  @override
  String get createTransactionButton => 'Crear Transacción';

  @override
  String get custom => 'Personalizado';

  @override
  String get cyan => 'Cían';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get deepPurple => 'Púrpura Profundo';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String deleteAccountConfirmation(String accountName) {
    return '¿Estás seguro de que deseas eliminar la cuenta \"$accountName\"? Esta acción no se puede deshacer.';
  }

  @override
  String get deleteAccountSuccess => 'Cuenta eliminada con éxito';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String deleteCategoryConfirmation(String categoryName) {
    return '¿Estás seguro de que deseas eliminar la categoría \"$categoryName\"? Esto también eliminará todas las transacciones asociadas.';
  }

  @override
  String get deleteCategoryTitle => 'Eliminar Categoría';

  @override
  String get deleteTransactionDescription => 'Esta acción no se puede deshacer.';

  @override
  String get deleteTransactionTitle => 'Eliminar Transacción';

  @override
  String get descriptionHint => 'Ingrese descripción de la transacción';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get edit => 'Editar';

  @override
  String get editCategory => 'Editar Categoría';

  @override
  String get editTransactionTitle => 'Editar Transacción';

  @override
  String get english => 'Inglés';

  @override
  String get englishNative => 'English';

  @override
  String get error_data_not_found => 'Los datos solicitados no fueron encontrados.';

  @override
  String error_data_not_found_entity(String entity) {
    return 'La $entity solicitada no fue encontrada.';
  }

  @override
  String get error_db_closed => 'La conexión con la base de datos no está disponible. Por favor, reinicia la aplicación.';

  @override
  String get error_db_constraint_violation => 'Se violó una restricción de la base de datos. Puede ser una entrada duplicada o una referencia no válida.';

  @override
  String get error_db_operation_failed => 'La operación en la base de datos falló. Inténtalo de nuevo.';

  @override
  String error_db_operation_failed_operation(String operation) {
    return 'No se pudo $operation. Inténtalo de nuevo.';
  }

  @override
  String get error_foreign_key_violation => 'No se puede completar la operación porque hace referencia a datos que ya no existen.';

  @override
  String error_foreign_key_violation_table(String table) {
    return 'No se puede completar la operación porque hace referencia a una $table que ya no existe.';
  }

  @override
  String get error_storage_full => 'El almacenamiento del dispositivo está lleno. Libera espacio e inténtalo de nuevo.';

  @override
  String get error_unique_constraint_violation => 'Este registro ya existe.';

  @override
  String error_unique_constraint_violation_field(String field) {
    return 'Ya existe un registro con este $field.';
  }

  @override
  String get error_unknown_data => 'Algo salió mal con la operación de datos. Inténtalo de nuevo.';

  @override
  String get errorCategoryNameEmpty => 'El nombre de la categoría no puede estar vacío';

  @override
  String get errorCategoryNameTooLong => 'El nombre de la categoría es demasiado largo';

  @override
  String get errorCategoryNameTooShort => 'El nombre de la categoría es demasiado corto';

  @override
  String errorLoadingAccounts(String error) {
    return 'Error al cargar las cuentas: $error';
  }

  @override
  String errorLoadingCalendar(String error) {
    return 'Error al cargar el calendario: $error';
  }

  @override
  String errorLoadingCategories(String error) {
    return 'Error al cargar las categorías: $error';
  }

  @override
  String errorLoadingTransaction(String error) {
    return 'Error al cargar transacción: $error';
  }

  @override
  String errorLoadingTransactions(String error) {
    return 'Error al cargar las transacciones: $error';
  }

  @override
  String get expense => 'Gasto';

  @override
  String get expenseType => 'Gasto';

  @override
  String get fabAddTransactionTooltip => 'Agregar transacción';

  @override
  String get fromAccountLabel => 'Cuenta de Origen';

  @override
  String get goBackAction => 'Regresar';

  @override
  String get helloWorld => '¡Hola Mundo!';

  @override
  String get income => 'Ingreso';

  @override
  String get incomeType => 'Ingreso';

  @override
  String get indigo => 'Índigo';

  @override
  String get language => 'Idioma';

  @override
  String get lime => 'Lima';

  @override
  String get more => 'Más';

  @override
  String get newTransactionTitle => 'Nueva Transacción';

  @override
  String get noAccountInfo => 'Sin información de cuenta';

  @override
  String get noDescription => 'Sin descripción';

  @override
  String noTransactionsOnDate(String date) {
    return 'Sin transacciones el $date';
  }

  @override
  String get primaryColor => 'Color primario';

  @override
  String get purple => 'Púrpura';

  @override
  String get selectAccountError => 'Por favor seleccione una cuenta';

  @override
  String get selectAccountHint => 'Seleccionar cuenta';

  @override
  String get selectAppLanguage => 'Selecciona el idioma de la aplicación';

  @override
  String get selectCategoryError => 'Por favor seleccione una categoría';

  @override
  String get selectCategoryHint => 'Seleccionar categoría';

  @override
  String get selectDateHint => 'Seleccionar fecha';

  @override
  String get selectTimeHint => 'Seleccionar hora';

  @override
  String get settings => 'Configuración';

  @override
  String get spanish => 'Español';

  @override
  String get spanishNative => 'Español';

  @override
  String get system => 'Sistema';

  @override
  String get teal => 'Verde azulado';

  @override
  String get theme => 'Tema';

  @override
  String get thisCategory => 'esta categoría';

  @override
  String get thisTransaction => 'esta transacción';

  @override
  String get timeLabel => 'Hora';

  @override
  String get toAccountLabel => 'Cuenta de Destino';

  @override
  String get transactionCreatedSuccess => '¡Transacción creada exitosamente!';

  @override
  String get transactionDeletedSuccess => 'Transacción eliminada exitosamente';

  @override
  String transactionDeleteError(String error) {
    return 'Error al eliminar transacción: $error';
  }

  @override
  String get transactionSaveError => 'Error al guardar transacción';

  @override
  String get transactionTitle => 'Transacción';

  @override
  String get transactionTypeLabel => 'Tipo de Transacción';

  @override
  String get transactionUpdatedSuccess => '¡Transacción actualizada exitosamente!';

  @override
  String get transferType => 'Transferencia';

  @override
  String get unknownCategory => 'Desconocida';

  @override
  String get update => 'Actualizar';

  @override
  String get updateTransactionButton => 'Actualizar Transacción';

  @override
  String get weekdayFri => 'Vie';

  @override
  String get weekdayMon => 'Lun';

  @override
  String get weekdaySat => 'Sáb';

  @override
  String get weekdaySun => 'Dom';

  @override
  String get weekdayThu => 'Jue';

  @override
  String get weekdayTue => 'Mar';

  @override
  String get weekdayWed => 'Mié';

  @override
  String get yellow => 'Amarillo';
}
