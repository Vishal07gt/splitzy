abstract class UiStates<T> {}

class DefaultState<T> implements UiStates<T> {
  DefaultState();
}

class Progress<T> implements UiStates<T> {
  Progress();
}

class Success<T> implements UiStates<T> {
  final T data;
  Success(this.data);
}

class Error<T> implements UiStates<T> {
  final String message;
  Error(this.message);
}
