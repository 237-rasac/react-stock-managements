-- =====================================================================
-- V6 — UserRole CHECK constraint
--
-- Older databases generated this constraint before SUPER_ADMIN existed,
-- causing the bootstrap initializer to fail when it upgrades the account.
-- Keep the database constraint aligned with UserRole.
-- =====================================================================

ALTER TABLE utilisateur DROP CONSTRAINT IF EXISTS utilisateur_role_check;
ALTER TABLE utilisateur
    ADD CONSTRAINT utilisateur_role_check
    CHECK (role IN ('SUPER_ADMIN', 'ADMIN', 'GESTIONNAIRE', 'VENDEUR'));
