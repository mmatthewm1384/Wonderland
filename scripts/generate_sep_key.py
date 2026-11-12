import Security


def generate_secure_enclave_key(tag_string: str):
    tag_data = tag_string.encode("utf-8")

    # Define access control to require biometric / device presence
    access_control, error = Security.SecAccessControlCreateWithFlags(
        None,
        Security.kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        Security.kSecAccessControlUserPresence,
        None,
    )
    if error is not None:
        print(f"[SEP Error] Failed to create access control: {error}")
        return False

    # Define key generation attributes for the Secure Enclave token
    attributes = {
        Security.kSecAttrKeyType: Security.kSecAttrKeyTypeECSECPrimeRandom,
        Security.kSecAttrKeySizeInBits: 256,
        Security.kSecPrivateKeyAttrs: {
            Security.kSecAttrIsPermanent: True,
            Security.kSecAttrApplicationTag: tag_data,
            Security.kSecAttrAccessControl: access_control,
        },
    }

    # PyObjC returns (result, error) tuple for functions taking CFErrorRef pointers
    private_key, error = Security.SecKeyCreateRandomKey(attributes, None)

    if error is not None:
        print(f"[SEP Error] Failed to generate key: {error}")
        return False

    print(f"[SEP] Successfully generated Secure Enclave P-256 key: {tag_string}")
    return True


if __name__ == "__main__":
    generate_secure_enclave_key("com.wonderland.sep.anchor_key")
