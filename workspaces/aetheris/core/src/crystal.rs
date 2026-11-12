use blake3;
use rkyv::{Archive, Deserialize, Serialize};
use uuid::Uuid;

#[derive(Archive, Serialize, Deserialize, Debug, Clone)]
#[archive(check_bytes)]
pub struct VectorIntersectionCache {
    pub query_timestamp: u64,
    pub threshold: f32,
    pub matches: Vec<(u32, f32)>,
    pub integrity_hash: String,
}

pub struct MemoryCrystal {
    pub id: Uuid,
    pub payload: Vec<u8>,
    pub signature: String,
}

#[derive(Debug)]
pub enum CrystalError {
    SerializationError(String),
    IntegrityError,
    InvalidArchive(String),
}

impl std::fmt::Display for CrystalError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::SerializationError(msg) => {
                write!(f, "Crystal serialization error: {msg}")
            }
            Self::IntegrityError => write!(f, "Crystal integrity verification failed"),
            Self::InvalidArchive(msg) => {
                write!(f, "Invalid Crystal archive: {msg}")
            }
        }
    }
}

impl std::error::Error for CrystalError {}

impl MemoryCrystal {
    pub fn seal_vector_intersections(
        scores: &[f32],
        threshold: f32,
        timestamp: u64,
    ) -> Result<Self, Box<dyn std::error::Error>> {
        if !threshold.is_finite() || scores.iter().any(|score| !score.is_finite()) {
            return Err(Box::new(CrystalError::SerializationError(
                "Scores and threshold must be finite".into(),
            )));
        }

        let matches: Vec<(u32, f32)> = scores
            .iter()
            .enumerate()
            .filter(|&(_, &score)| score >= threshold)
            .map(|(idx, &score)| (idx as u32, score))
            .collect();

        let cache_record = VectorIntersectionCache {
            query_timestamp: timestamp,
            threshold,
            matches,
            integrity_hash: String::new(),
        };

        let bytes = rkyv::to_bytes::<_, 256>(&cache_record)
            .map_err(|e| CrystalError::SerializationError(e.to_string()))?;

        let payload = bytes.into_vec();
        let signature = blake3::hash(&payload).to_hex().to_string();

        Ok(Self {
            id: Uuid::new_v4(),
            payload,
            signature,
        })
    }

    pub fn deserialize_from_bytes(
        bytes: &[u8],
    ) -> Result<Self, Box<dyn std::error::Error>> {
        validate_archive(bytes)?;

        Ok(Self {
            id: Uuid::new_v4(),
            payload: bytes.to_vec(),
            signature: blake3::hash(bytes).to_hex().to_string(),
        })
    }

    pub fn verify(&self) -> bool {
        blake3::hash(&self.payload).to_hex().as_str() == self.signature
            && validate_archive(&self.payload).is_ok()
    }

    pub fn inspect_matches<F, R>(
        &self,
        f: F,
    ) -> Result<R, Box<dyn std::error::Error>>
    where
        F: FnOnce(&ArchivedVectorIntersectionCache) -> R,
    {
        if !self.verify() {
            return Err(Box::new(CrystalError::IntegrityError));
        }

        let archived = rkyv::check_archived_root::<VectorIntersectionCache>(
            &self.payload,
        )
        .map_err(|e| {
            Box::new(CrystalError::InvalidArchive(e.to_string()))
                as Box<dyn std::error::Error>
        })?;

        Ok(f(archived))
    }
}

fn validate_archive(
    bytes: &[u8],
) -> Result<(), Box<dyn std::error::Error>> {
    rkyv::check_archived_root::<VectorIntersectionCache>(bytes)
        .map(|_| ())
        .map_err(|e| {
            Box::new(CrystalError::InvalidArchive(e.to_string()))
                as Box<dyn std::error::Error>
        })
}
