class UserMessageKey {
  final String key; // e.g. 'error_db_closed'
  final Map<String, Object>? args;

  const UserMessageKey(this.key, {this.args});
}
