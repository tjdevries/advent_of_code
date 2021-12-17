use anyhow::Result;
use itertools::Itertools;

fn descending_window(size: usize) -> Result<usize> {
    Ok(aoc::read_one_per_line::<u32>("./data/1.input")?
        .windows(size)
        .filter(|win| win[0] < win[size - 1])
        .collect_vec()
        .len())
}

fn main() -> Result<()> {
    println!("Part 1: {}", descending_window(2)?);
    println!("Part 2: {}", descending_window(4)?);

    Ok(())
}
