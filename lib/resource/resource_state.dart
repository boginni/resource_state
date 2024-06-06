import 'package:flutter/material.dart';
import 'resource_state_enum.dart';

class ResourceState<S> extends ChangeNotifier {
  S? data;
  Exception? error;
  ResourceStateEnum _state;
  ResourceStateEnum? _lastState;

  ResourceStateEnum get state => _state;

  S get getData => data!;

  ResourceState({
    required this.data,
    required ResourceStateEnum state,
    this.error,
  }) : _state = state;

  factory ResourceState.loading() {
    return ResourceState(
      state: ResourceStateEnum.LOADING,
      data: null,
    );
  }

  factory ResourceState.success(S data) {
    return ResourceState(
      state: ResourceStateEnum.SUCCESS,
      data: data,
    );
  }

  factory ResourceState.emptySuccess() {
    return ResourceState(
      state: ResourceStateEnum.EMPTY_SUCCESS,
      data: null,
    );
  }

  factory ResourceState.error(Exception error) {
    return ResourceState(
      state: ResourceStateEnum.ERROR,
      error: error,
      data: null,
    );
  }

  factory ResourceState.waiting() {
    return ResourceState(
      state: ResourceStateEnum.WAITING,
      data: null,
    );
  }

  bool get isWaiting => _state == ResourceStateEnum.WAITING;

  bool get isLoading => _state == ResourceStateEnum.LOADING;

  bool get isSuccess => _state == ResourceStateEnum.SUCCESS;

  bool get isEmptySuccess => _state == ResourceStateEnum.EMPTY_SUCCESS;

  bool get isError => _state == ResourceStateEnum.ERROR;

  void setState(
      {S? data,
      ResourceStateEnum state = ResourceStateEnum.SUCCESS,
      Exception? error,
      bool notify = true,}) {
    _state = state;
    this.data = data;
    this.error = error;
    if (notify) {
      notifyListeners();
    }
  }

  void _updateState({
    S? data,
    ResourceStateEnum? state,
    Exception? error,
    bool notify = true,
  }) {
    if (state != null) _state = state;
    if (data != null) this.data = data;
    if (error != null) this.error = error;
    if (notify) notifyListeners();
  }

  void add(S data, {bool notify = true}) {
    final newState = (data is List && data.isEmpty) || data == null
        ? ResourceStateEnum.EMPTY_SUCCESS
        : ResourceStateEnum.SUCCESS;

    _updateState(data: data, state: newState, notify: notify);
  }

  void setError({
    Exception? error,
    ResourceStateEnum state = ResourceStateEnum.ERROR,
    bool notify = true,
  }) {
    setState(state: state, error: error, notify: notify);
  }

  void setLoading({
    bool notify = true,
  }) {
    _state = ResourceStateEnum.LOADING;

    if (notify) {
      notifyListeners();
    }
  }

  Future<void> load(Future<S> future) async {
    setLoading();
    try {
      add(await future);
    } catch (e) {
      if (e is Exception) {
        setError(error: e);
      } else {
        setError(error: Exception('Unknown error'));
      }
    }
  }

  void beginWaiting() {
    _lastState = _state;
    _state = ResourceStateEnum.WAITING;
    notifyListeners();
  }

  void finishWaiting() {
    if (_lastState == null) {
      return;
    }
    _state = _lastState!;
    notifyListeners();
  }
}
