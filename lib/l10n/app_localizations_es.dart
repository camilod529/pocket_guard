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
  String get accountFilterLabel => 'Cuenta';

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
  String get activeLabel => 'Activo';

  @override
  String get addBudget => 'Agregar Presupuesto';

  @override
  String get addGoal => 'Agregar Meta';

  @override
  String get addRecurringTransaction => 'Agregar Transacción Recurrente';

  @override
  String get addWishlistItem => 'Agregar Artículo';

  @override
  String get allAccounts => 'Todas las Cuentas';

  @override
  String get amountHint => '0.00';

  @override
  String get amountLabel => 'Monto';

  @override
  String get applyFilters => 'Aplicar Filtros';

  @override
  String get archivedGoalsSection => 'Archivadas';

  @override
  String get backupAndRestore => 'Copia de Seguridad';

  @override
  String get backupAndRestoreSubtitle => 'Guarda tus datos en un archivo o recupéralos';

  @override
  String backupCreatedOn(String date) {
    return 'Creada el $date';
  }

  @override
  String get backupErrorCorrupted => 'Esta copia está dañada y no se puede restaurar.';

  @override
  String get backupErrorNewerFormat => 'Esta copia se hizo con una versión más nueva de PocketGuard. Actualiza la app para restaurarla.';

  @override
  String get backupErrorNotABackup => 'Este archivo no es una copia de PocketGuard.';

  @override
  String get backupErrorWrongPassword => 'Contraseña incorrecta, o el archivo fue modificado.';

  @override
  String get backupFailed => 'No se pudo crear la copia';

  @override
  String backupItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
      zero: 'Vacío',
    );
    return '$_temp0';
  }

  @override
  String get backupPasswordConfirmLabel => 'Repite la contraseña';

  @override
  String get backupPasswordHelper => 'Cifra el archivo para que solo tú puedas abrirlo';

  @override
  String get backupPasswordLabel => 'Contraseña (opcional)';

  @override
  String get backupPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get backupPasswordPrompt => 'Ingresa la contraseña con la que se creó esta copia.';

  @override
  String get backupPasswordPromptTitle => 'Copia Protegida';

  @override
  String get backupPasswordWarning => 'Si olvidas esta contraseña, la copia no se podrá restaurar.';

  @override
  String get backupSectionBudgets => 'Presupuestos';

  @override
  String get backupSectionBudgetsDescription => 'Límites mensuales por categoría';

  @override
  String get backupSectionCategories => 'Categorías';

  @override
  String get backupSectionCategoriesDescription => 'Tus categorías de ingresos y gastos';

  @override
  String get backupSectionMoney => 'Cuentas y Dinero';

  @override
  String get backupSectionMoneyDescription => 'Cuentas, transacciones, transacciones recurrentes y metas de ahorro';

  @override
  String get backupSectionRequired => 'La necesitan las otras secciones que elegiste';

  @override
  String get backupSectionSettings => 'Ajustes';

  @override
  String get backupSectionSettingsDescription => 'Tema e idioma';

  @override
  String get backupSectionWishlist => 'Lista de Deseos';

  @override
  String get backupSectionWishlistDescription => 'Cosas que quieres comprar';

  @override
  String get backupUnlockButton => 'Desbloquear';

  @override
  String get backupWorking => 'Procesando…';

  @override
  String get balanceTrend => 'Tendencia del Saldo';

  @override
  String get blue => 'Azul';

  @override
  String get budgetCurrencyNoAccountsHint => 'Agrega una cuenta primero para establecer la moneda del presupuesto';

  @override
  String get budgetDeletedSuccess => 'Presupuesto eliminado con éxito';

  @override
  String get budgetDuplicateCategoryCurrencyError => 'Ya tienes un presupuesto para esta categoría en esta moneda';

  @override
  String get budgets => 'Presupuestos';

  @override
  String get buyWishlistItem => 'Comprar';

  @override
  String get calendar => 'Calendario';

  @override
  String get calendarNextMonth => 'Mes siguiente';

  @override
  String get calendarPreviousMonth => 'Mes anterior';

  @override
  String get calendarToday => 'Ir a hoy';

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
  String get categoryInUseError => 'Esta categoría aún la usan transacciones, transacciones recurrentes o presupuestos, así que no se puede eliminar.';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get categoryName => 'Nombre de Categoría';

  @override
  String get chooseBackupFileButton => 'Elegir Archivo';

  @override
  String get chooseYourAppColor => 'Elige el color de tu aplicación';

  @override
  String get clearAll => 'Borrar Todo';

  @override
  String get contributionAmountLabel => 'Monto';

  @override
  String get contributionFromAccountLabel => 'Desde la cuenta';

  @override
  String get contributionNoteLabel => 'Nota (opcional)';

  @override
  String get contributionToAccountLabel => 'A la cuenta';

  @override
  String get create => 'Crear';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get createBackupButton => 'Crear Copia';

  @override
  String get createBackupDescription => 'Elige qué incluir. Luego puedes guardar el archivo en Google Drive, Archivos o donde quieras.';

  @override
  String get createBackupTitle => 'Crear una Copia';

  @override
  String get createBudgetButton => 'Crear Presupuesto';

  @override
  String get createCategory => 'Crear Categoría';

  @override
  String get createGoalButton => 'Crear Meta';

  @override
  String get createRecurringTransactionButton => 'Crear Transacción Recurrente';

  @override
  String get createTransaction => 'Crear Transacción';

  @override
  String get createTransactionButton => 'Crear Transacción';

  @override
  String get createWishlistItemButton => 'Agregar a la Lista';

  @override
  String get currencyLabel => 'Moneda';

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
  String deleteAccountConfirmation(String accountName) {
    return '¿Estás seguro de que deseas eliminar la cuenta \"$accountName\"? Esto también eliminará todas las transacciones y transacciones recurrentes asociadas.';
  }

  @override
  String get deleteAccountSuccess => 'Cuenta eliminada con éxito';

  @override
  String get deleteAccountTitle => 'Eliminar Cuenta';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get deleteBudgetDescription => 'Esta acción no se puede deshacer.';

  @override
  String get deleteBudgetTitle => 'Eliminar Presupuesto';

  @override
  String deleteCategoryConfirmation(String categoryName) {
    return '¿Estás seguro de que deseas eliminar la categoría \"$categoryName\"? Esto también eliminará todas las transacciones asociadas.';
  }

  @override
  String get deleteCategoryTitle => 'Eliminar Categoría';

  @override
  String deleteConfirmationQuestion(String entity) {
    return '¿Estás seguro de que deseas eliminar \"$entity\"?';
  }

  @override
  String get deleteContributionDescription => 'El dinero vuelve a la cuenta de donde salió.';

  @override
  String get deleteContributionTitle => 'Eliminar Movimiento';

  @override
  String get deletedAccountLabel => 'Cuenta eliminada';

  @override
  String get deleteGoalDescription => 'La meta y su historial se eliminarán.';

  @override
  String deleteGoalRefundPrompt(String amount) {
    return 'Esta meta tiene $amount. Elige la cuenta que lo recibe de vuelta.';
  }

  @override
  String get deleteGoalTitle => 'Eliminar Meta';

  @override
  String get deleteRecurringTransactionDescription => 'Esta acción no se puede deshacer. Las transacciones ya generadas por esta regla no se verán afectadas.';

  @override
  String get deleteRecurringTransactionTitle => 'Eliminar Transacción Recurrente';

  @override
  String get deleteTransactionDescription => 'Esta acción no se puede deshacer.';

  @override
  String get deleteTransactionTitle => 'Eliminar Transacción';

  @override
  String get deleteWishlistItemTitle => 'Eliminar Artículo';

  @override
  String get depositToGoal => 'Agregar Dinero';

  @override
  String get descriptionHint => 'Ingrese descripción de la transacción';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get edit => 'Editar';

  @override
  String get editBudgetTitle => 'Editar Presupuesto';

  @override
  String get editCategory => 'Editar Categoría';

  @override
  String get editGoalTitle => 'Editar Meta';

  @override
  String get editRecurringTransactionTitle => 'Editar Transacción Recurrente';

  @override
  String get editTransactionTitle => 'Editar Transacción';

  @override
  String get editWishlistItemTitle => 'Editar Artículo';

  @override
  String get endDateLabel => 'Fecha de Finalización';

  @override
  String get english => 'Inglés';

  @override
  String get englishNative => 'English';

  @override
  String get error_db_operation_failed => 'La operación en la base de datos falló. Inténtalo de nuevo.';

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
  String get expensesByCategory => 'Gastos por Categoría';

  @override
  String get expenseType => 'Gasto';

  @override
  String get filterTitle => 'Filtrar Transacciones';

  @override
  String get french => 'Francés';

  @override
  String get frenchNative => 'Français';

  @override
  String get frequencyDaily => 'Diario';

  @override
  String get frequencyLabel => 'Frecuencia';

  @override
  String get frequencyMonthly => 'Mensual';

  @override
  String get frequencyWeekly => 'Semanal';

  @override
  String get frequencyYearly => 'Anual';

  @override
  String get fromAccountLabel => 'Cuenta de Origen';

  @override
  String get goalAmountError => 'El monto debe ser mayor que 0';

  @override
  String get goalArchivedLabel => 'Archivada';

  @override
  String get goalArchivedSubtitle => 'Ocultarla de las metas activas';

  @override
  String get goalCompleted => '¡Meta alcanzada!';

  @override
  String get goalCurrencyLockedHint => 'Bloqueada: la meta ya tiene dinero';

  @override
  String get goalCurrencyNoAccountsHint => 'Agrega una cuenta primero para establecer la moneda de la meta';

  @override
  String get goalDeletedSuccess => 'Meta eliminada';

  @override
  String get goalDepositSuccess => 'Dinero agregado a la meta';

  @override
  String get goalErrorAccountMissing => 'La cuenta de este movimiento fue eliminada, así que no se puede cambiar';

  @override
  String get goalErrorCurrencyLocked => 'No puedes cambiar la moneda de una meta que ya tiene dinero';

  @override
  String get goalErrorCurrencyMismatch => 'La moneda de la cuenta no coincide con la de la meta';

  @override
  String get goalErrorInsufficientAccountBalance => 'La cuenta no tiene suficiente dinero';

  @override
  String get goalErrorInsufficientGoalBalance => 'La meta no tiene ahorrado tanto';

  @override
  String get goalErrorRefundAccountRequired => 'Elige una cuenta para recibir el dinero ahorrado';

  @override
  String get goalHistory => 'Historial';

  @override
  String goalMonthlyNeeded(String amount, String date) {
    return 'Ahorra $amount/mes para lograrla antes del $date';
  }

  @override
  String get goalNameHint => 'p. ej. Carro nuevo';

  @override
  String get goalNameLabel => 'Nombre de la meta';

  @override
  String get goalNameRequired => 'Ingresa un nombre';

  @override
  String get goalOverdue => 'La fecha objetivo ya pasó';

  @override
  String get goals => 'Metas de Ahorro';

  @override
  String goalSavedOf(String saved, String target) {
    return '$saved de $target';
  }

  @override
  String get goalTargetAmountLabel => 'Monto objetivo';

  @override
  String get goalTargetDateLabel => 'Fecha objetivo (opcional)';

  @override
  String get goalWithdrawSuccess => 'Dinero retirado de la meta';

  @override
  String get goBackAction => 'Regresar';

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
  String get manageBudgets => 'Establece límites de gasto mensuales por categoría';

  @override
  String get manageGoals => 'Ahorra dinero para algo que quieras';

  @override
  String get manageRecurringTransactions => 'Administra suscripciones y pagos recurrentes';

  @override
  String get manageWishlist => 'Mira si puedes pagar lo que quieres';

  @override
  String get monthlyInsights => 'Perspectivas Mensuales';

  @override
  String get monthlyLimitHint => '0.00';

  @override
  String get monthlyLimitLabel => 'Límite Mensual';

  @override
  String get more => 'Más';

  @override
  String get newBudgetTitle => 'Nuevo Presupuesto';

  @override
  String get newGoalTitle => 'Nueva Meta';

  @override
  String get newRecurringTransactionTitle => 'Nueva Transacción Recurrente';

  @override
  String get newTransactionTitle => 'Nueva Transacción';

  @override
  String get newWishlistItemTitle => 'Nuevo Artículo';

  @override
  String get nextOccurrenceLabel => 'Próxima';

  @override
  String get noAccountInfo => 'Sin información de cuenta';

  @override
  String get noBudgetsMessage => 'Aún no hay presupuestos';

  @override
  String get noContributionsMessage => 'Aún no has agregado dinero';

  @override
  String get noDataForPeriod => 'No hay datos para este período';

  @override
  String get noDescription => 'Sin descripción';

  @override
  String get noEndDateLabel => 'Sin fecha de finalización';

  @override
  String get noExpensesFound => 'No se encontraron gastos';

  @override
  String get noGoalsMessage => 'Aún no tienes metas de ahorro';

  @override
  String get noRecurringTransactionsMessage => 'Aún no hay transacciones recurrentes';

  @override
  String noTransactionsOnDate(String date) {
    return 'Sin transacciones el $date';
  }

  @override
  String get noWishlistItemsMessage => 'Tu lista de deseos está vacía';

  @override
  String get primaryColor => 'Color primario';

  @override
  String get purple => 'Púrpura';

  @override
  String get recurringTransactionDeletedSuccess => 'Transacción recurrente eliminada correctamente';

  @override
  String get recurringTransactionNameHint => 'ej. Netflix, Alquiler';

  @override
  String get recurringTransactionNameLabel => 'Nombre';

  @override
  String get recurringTransactions => 'Transacciones Recurrentes';

  @override
  String get remainingLabel => 'Restante';

  @override
  String get restoreBackupDescription => 'Abre un archivo .pgbackup y elige qué recuperar.';

  @override
  String get restoreBackupTitle => 'Restaurar una Copia';

  @override
  String get restoreButton => 'Restaurar';

  @override
  String get restoreChooseSections => '¿Qué quieres restaurar?';

  @override
  String get restoreConfirmMessage => 'Tus datos actuales en las secciones elegidas se reemplazarán por los de la copia. No se puede deshacer.';

  @override
  String get restoreConfirmTitle => '¿Reemplazar tus Datos?';

  @override
  String get restoreFailed => 'La restauración falló. No se cambió nada.';

  @override
  String get restoreReplaceNote => 'Las secciones que elijas reemplazan lo que hay ahora en este teléfono. Las categorías se agregan, nunca se eliminan.';

  @override
  String get restoreSuccess => 'Copia restaurada';

  @override
  String get sameTransferAccountError => 'Las cuentas de origen y destino deben ser diferentes';

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
  String get spentLabel => 'Gastado';

  @override
  String get startDateLabel => 'Fecha de Inicio';

  @override
  String get system => 'Sistema';

  @override
  String get teal => 'Verde azulado';

  @override
  String get theme => 'Tema';

  @override
  String get thisAccount => 'esta cuenta';

  @override
  String get thisBudget => 'este presupuesto';

  @override
  String get thisCategory => 'esta categoría';

  @override
  String get thisContribution => 'este movimiento';

  @override
  String get thisGoal => 'esta meta';

  @override
  String get thisRecurringTransaction => 'esta transacción recurrente';

  @override
  String get thisTransaction => 'esta transacción';

  @override
  String get thisWishlistItem => 'este artículo';

  @override
  String get timeLabel => 'Hora';

  @override
  String get toAccountLabel => 'Cuenta de Destino';

  @override
  String get totalExpense => 'Gastos Totales';

  @override
  String get totalIncome => 'Ingresos Totales';

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
  String transferSummary(String amount, String fromAccount, String toAccount) {
    return 'Esto moverá $amount de $fromAccount a $toAccount.';
  }

  @override
  String get transferType => 'Transferencia';

  @override
  String get unknownCategory => 'Desconocida';

  @override
  String get update => 'Actualizar';

  @override
  String get updateBudgetButton => 'Actualizar Presupuesto';

  @override
  String get updateGoalButton => 'Actualizar Meta';

  @override
  String get updateRecurringTransactionButton => 'Actualizar Transacción Recurrente';

  @override
  String get updateTransactionButton => 'Actualizar Transacción';

  @override
  String get updateWishlistItemButton => 'Actualizar Artículo';

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
  String get wishlist => 'Lista de Deseos';

  @override
  String get wishlistAffordable => 'Puedes pagarlo';

  @override
  String get wishlistCategoryLabel => 'Categoría (opcional)';

  @override
  String wishlistCoveredByGoal(String goal) {
    return 'Cubierto por tu ahorro \"$goal\"';
  }

  @override
  String get wishlistCurrencyNoAccountsHint => 'Agrega una cuenta primero para establecer la moneda';

  @override
  String get wishlistDeletedSuccess => 'Artículo eliminado';

  @override
  String get wishlistGoalLabel => 'Pagar con meta de ahorro (opcional)';

  @override
  String wishlistInsufficientFunds(String amount) {
    return 'Te faltan $amount';
  }

  @override
  String get wishlistItemNameHint => 'p. ej. Audífonos';

  @override
  String get wishlistItemNameLabel => '¿Qué quieres?';

  @override
  String get wishlistNone => 'Ninguna';

  @override
  String wishlistOverBudget(String amount) {
    return '$amount por encima del presupuesto del mes';
  }

  @override
  String get wishlistPriceLabel => 'Precio';

  @override
  String wishlistPurchasedOn(String date) {
    return 'Comprado el $date';
  }

  @override
  String get wishlistPurchasedSection => 'Comprados';

  @override
  String get wishlistPurchasedSuccess => 'Marcado como comprado';

  @override
  String get wishlistUseGoalConfirm => 'Usar Ahorros';

  @override
  String wishlistUseGoalPrompt(String amount, String goal) {
    return 'Mueve $amount de \"$goal\" a esta cuenta para pagarlo:';
  }

  @override
  String get wishlistUseGoalSkip => 'No Usar';

  @override
  String get wishlistUseGoalTitle => '¿Usar tus Ahorros?';

  @override
  String get withdrawFromGoal => 'Retirar';

  @override
  String get yellow => 'Amarillo';
}
