use anyhow::Result;
use itertools::Itertools;

fn main() -> Result<()> {
    let part1 = aoc::read_one_per_line::<u32>("./data/1.input")?
        .windows(2)
        .filter(|win| win[0] < win[1])
        .collect_vec()
        .len();

    println!("Part 1: {}", part1);

    let part2 = aoc::read_one_per_line::<u32>("./data/1.input")?
        .windows(4)
        .filter(|win| win[0] < win[3])
        .collect_vec()
        .len();

    println!("Part 2: {:?}", part2);

    Ok(())
}
