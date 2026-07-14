/// Generic view state used by providers so every screen can render
/// loading, error, and empty states consistently instead of guessing
/// from nullable fields.
enum ViewState { initial, loading, loaded, empty, error }
