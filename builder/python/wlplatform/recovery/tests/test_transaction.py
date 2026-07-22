from wlplatform.recovery.transaction import RecoveryTransaction


def test_transaction_creation(tmp_path):

    tx = RecoveryTransaction(tmp_path)

    path = tx.create()

    assert path.exists()
    assert (path / "transaction.json").exists()
