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

pub fn read_one_line<T>(path: &str, sep: &str) -> Result<Vec<T>>
where
    T: FromStr,
{
    Ok(std::fs::read_to_string(path)?
        .trim()
        .split(sep)
        .filter_map(|c| c.parse::<T>().ok())
        .collect())
}

pub fn cardinal_directions(
    x: usize,
    y: usize,
    x_bound: usize,
    y_bound: usize,
) -> Vec<(usize, usize)> {
    let mut dirs = Vec::new();

    if let Some(x) = x.checked_sub(1) {
        dirs.push((x, y));
    }

    if let Some(y) = y.checked_sub(1) {
        dirs.push((x, y));
    }

    if let Some(x) = x.checked_add(1) {
        if x < x_bound {
            dirs.push((x, y));
        }
    }

    if let Some(y) = y.checked_add(1) {
        if y < y_bound {
            dirs.push((x, y));
        }
    }

    dirs
}
