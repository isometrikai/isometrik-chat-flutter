class ModelWrapperExample<T> {
  const ModelWrapperExample({
    required this.data,
    required this.statusCode,
  });
  final T? data;
  final int statusCode;
}
