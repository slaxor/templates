#![no_std]

/// Returns the initial state for the example application.
///
/// Keep reusable, hardware-independent logic in this crate.
pub const fn initial_state() -> bool {
    false
}

#[cfg(test)]
mod tests {
    use super::initial_state;

    #[test]
    fn initial_state_is_off() {
        assert!(!initial_state());
    }
}
