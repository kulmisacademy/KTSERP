/** Letters and/or digits only — min 8 chars. No symbols or case rules. */
export function validatePassword(password: string): string | null {
  if (password.length < 8) {
    return "Password must be at least 8 characters";
  }
  if (!/^[A-Za-z0-9]+$/.test(password)) {
    return "Use letters and numbers only (no symbols or spaces)";
  }
  return null;
}
