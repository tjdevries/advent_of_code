use anyhow::Result;
use std::str::FromStr;

pub fn read_one_per_line<T>(path: &str) -> Result<Vec<T>>
where
    T: FromStr,
{
    Ok(std::fs::read_to_string(path)?
        .lines()
        .filter_map(|line| line.parse::<T>().ok())
        .collect())
}

pub fn read_vec_per_line<T, F>(path: &str, f: F) -> Result<Vec<Vec<T>>>
where
    T: FromStr,
    F: Fn(char) -> Option<T>,
{
    Ok(std::fs::read_to_string(path)?
        .lines()
        .map(|line| line.chars().map(|c| f(c).unwrap()).collect())
        .collect())
}
