// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get accountCurrency => 'Devise';

  @override
  String get accountCurrencyHint => 'USD, EUR, GBP';

  @override
  String get accountDeletedSuccessfully => 'Compte supprimé avec succès';

  @override
  String accountLabel(String name) {
    return 'Compte';
  }

  @override
  String get accountName => 'Nom du compte';

  @override
  String get accountNameHint => 'Entrez le nom du compte';

  @override
  String get accounts => 'Comptes';

  @override
  String get accountTypeAsset => 'Actif';

  @override
  String get accountTypeCash => 'Espèces';

  @override
  String get accountTypeCredit => 'Crédit';

  @override
  String get accountTypeLabel => 'Type de compte';

  @override
  String get addAccount => 'Ajouter un compte';

  @override
  String get amountHint => '0,00';

  @override
  String get amountLabel => 'Somme';

  @override
  String get appTitle => 'Gestionnaire de Budget';

  @override
  String get blue => 'Bleu';

  @override
  String get calendar => 'Calendrier';

  @override
  String get calendarGoToToday => 'Aller à aujourd\'hui';

  @override
  String get calendarNextMonth => 'Mois suivant';

  @override
  String get calendarPreviousMonth => 'Mois dernier';

  @override
  String get cancel => 'Annuler';

  @override
  String get categories => 'Catégories';

  @override
  String get category_expense_food_dining => 'Alimentation';

  @override
  String get category_expense_rent => 'Loyer';

  @override
  String get category_expense_transportation => 'Transport';

  @override
  String get category_income_freelance => 'Freelance';

  @override
  String get category_income_salary => 'Salaire';

  @override
  String get category_transfer => 'Virement';

  @override
  String get categoryDeletedSuccessfully => 'Catégorie supprimée avec succès';

  @override
  String categoryDeleteError(String error) {
    return 'Erreur lors de la suppression de la catégorie : $error';
  }

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get categoryName => 'Nom de la catégorie';

  @override
  String get chooseYourAppColor => 'Choisissez la couleur de votre application';

  @override
  String get create => 'Créer';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get createCategory => 'Créer une catégorie';

  @override
  String get createTransaction => 'Créer une transaction';

  @override
  String get createTransactionButton => 'Créer la transaction';

  @override
  String get custom => 'Personnalisé';

  @override
  String get cyan => 'Cyan';

  @override
  String get dateLabel => 'Date';

  @override
  String get deepPurple => 'Violet profond';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String deleteAccountConfirmation(String accountName) {
    return 'Êtes-vous sûr de vouloir supprimer le compte « $accountName » ? Cette action est irréversible.';
  }

  @override
  String get deleteAccountSuccess => 'Compte supprimé avec succès';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String deleteCategoryConfirmation(String categoryName) {
    return 'Êtes-vous sûr de vouloir supprimer la catégorie « $categoryName » ? Cela supprimera également toutes les transactions associées.';
  }

  @override
  String get deleteCategoryTitle => 'Supprimer la catégorie';

  @override
  String get deleteTransactionDescription => 'Cette action est irréversible.';

  @override
  String get deleteTransactionTitle => 'Supprimer la transaction';

  @override
  String get descriptionHint => 'Entrez la description de la transaction';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get edit => 'Modifier';

  @override
  String get editCategory => 'Modifier la catégorie';

  @override
  String get editTransactionTitle => 'Modifier la transaction';

  @override
  String get english => 'Anglais';

  @override
  String get englishNative => 'English';

  @override
  String get error_data_not_found => 'Les données demandées n\'ont pas été trouvées.';

  @override
  String error_data_not_found_entity(String entity) {
    return 'L\'élément $entity demandé n\'a pas été trouvé.';
  }

  @override
  String get error_db_closed => 'La connexion à la base de données n\'est pas disponible. Veuillez redémarrer l\'application.';

  @override
  String get error_db_constraint_violation => 'Une contrainte de base de données a été violée. Il peut s\'agir d\'une entrée en double ou d\'une référence invalide.';

  @override
  String get error_db_operation_failed => 'L\'opération sur la base de données a échoué. Veuillez réessayer.';

  @override
  String error_db_operation_failed_operation(String operation) {
    return 'Impossible de $operation. Veuillez réessayer.';
  }

  @override
  String get error_foreign_key_violation => 'Impossible de terminer l\'opération car elle fait référence à des données qui n\'existent plus.';

  @override
  String error_foreign_key_violation_table(String table) {
    return 'Impossible de terminer l\'opération car elle fait référence à un(e) $table qui n\'existe plus.';
  }

  @override
  String get error_storage_full => 'L\'espace de stockage de l\'appareil est plein. Veuillez libérer de l\'espace et réessayer.';

  @override
  String get error_unique_constraint_violation => 'Cet enregistrement existe déjà.';

  @override
  String error_unique_constraint_violation_field(String field) {
    return 'Un enregistrement avec ce champ $field existe déjà.';
  }

  @override
  String get error_unknown_data => 'Une erreur est survenue lors de l\'opération de données. Veuillez réessayer.';

  @override
  String get errorCategoryNameEmpty => 'Le nom de la catégorie ne peut pas être vide';

  @override
  String get errorCategoryNameTooLong => 'Le nom de la catégorie est trop long';

  @override
  String get errorCategoryNameTooShort => 'Le nom de la catégorie est trop court';

  @override
  String errorLoadingAccounts(String error) {
    return 'Erreur lors du chargement des comptes : $error';
  }

  @override
  String errorLoadingCalendar(String error) {
    return 'Erreur lors du chargement du calendrier : $error';
  }

  @override
  String errorLoadingCategories(String error) {
    return 'Erreur lors du chargement des catégories : $error';
  }

  @override
  String errorLoadingTransaction(String error) {
    return 'Erreur lors du chargement de la transaction : $error';
  }

  @override
  String errorLoadingTransactions(String error) {
    return 'Erreur lors du chargement des transactions : $error';
  }

  @override
  String get expense => 'Dépense';

  @override
  String get expenseType => 'Dépense';

  @override
  String get fabAddTransactionTooltip => 'Ajouter une transaction';

  @override
  String get french => 'Français';

  @override
  String get frenchNative => 'Français';

  @override
  String get fromAccountLabel => 'Compte source';

  @override
  String get goBackAction => 'Retour';

  @override
  String get helloWorld => 'Bonjour le monde !';

  @override
  String get income => 'Revenu';

  @override
  String get incomeType => 'Revenu';

  @override
  String get indigo => 'Indigo';

  @override
  String get language => 'Langue';

  @override
  String get lime => 'Citron vert';

  @override
  String get more => 'Plus';

  @override
  String get newTransactionTitle => 'Nouvelle transaction';

  @override
  String get noAccountInfo => 'Aucune information de compte';

  @override
  String get noDescription => 'Aucune description';

  @override
  String noTransactionsOnDate(String date) {
    return 'Aucune transaction le $date';
  }

  @override
  String get primaryColor => 'Couleur primaire';

  @override
  String get purple => 'Violet';

  @override
  String get selectAccountError => 'Veuillez sélectionner un compte';

  @override
  String get selectAccountHint => 'Sélectionner un compte';

  @override
  String get selectAppLanguage => 'Sélectionnez la langue de l\'application';

  @override
  String get selectCategoryError => 'Veuillez sélectionner une catégorie';

  @override
  String get selectCategoryHint => 'Sélectionner une catégorie';

  @override
  String get selectDateHint => 'Sélectionner une date';

  @override
  String get selectTimeHint => 'Sélectionner une heure';

  @override
  String get settings => 'Paramètres';

  @override
  String get spanish => 'Espagnol';

  @override
  String get spanishNative => 'Español';

  @override
  String get system => 'Système';

  @override
  String get teal => 'Sarcelle';

  @override
  String get theme => 'Thème';

  @override
  String get thisCategory => 'cette catégorie';

  @override
  String get thisTransaction => 'cette transaction';

  @override
  String get timeLabel => 'Heure';

  @override
  String get toAccountLabel => 'Compte de destination';

  @override
  String get transactionCreatedSuccess => 'Transaction créée avec succès !';

  @override
  String get transactionDeletedSuccess => 'Transaction supprimée avec succès';

  @override
  String transactionDeleteError(String error) {
    return 'Erreur lors de la suppression de la transaction : $error';
  }

  @override
  String get transactionSaveError => 'Erreur lors de l\'enregistrement de la transaction';

  @override
  String get transactionTitle => 'Transaction';

  @override
  String get transactionTypeLabel => 'Type de transaction';

  @override
  String get transactionUpdatedSuccess => 'Transaction mise à jour avec succès !';

  @override
  String get transferType => 'Virement';

  @override
  String get unknownCategory => 'Inconnue';

  @override
  String get update => 'Mettre à jour';

  @override
  String get updateTransactionButton => 'Mettre à jour la transaction';

  @override
  String get weekdayFri => 'Ven';

  @override
  String get weekdayMon => 'Lun';

  @override
  String get weekdaySat => 'Sam';

  @override
  String get weekdaySun => 'Dim';

  @override
  String get weekdayThu => 'Jeu';

  @override
  String get weekdayTue => 'Mar';

  @override
  String get weekdayWed => 'Mer';

  @override
  String get yellow => 'Jaune';
}
