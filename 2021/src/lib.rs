use anyhow::Result;
use std::str::FromStr;

pub fn read_one_per_line<T>(path: &str) -> Result<Vec<T>>
where
    T: FromStr,
{
    Ok(std::fs::read_to_string(path)?
        .split("\n")
        .filter_map(|line| line.parse::<T>().ok())
        .collect())
}
