use std::collections::VecDeque;

use anyhow::Result;
use itertools::Itertools;

// TODO: If I want to come back and be really clever,
// it seems like it should be possible to just calculate this, rather than
// simulate it... not 100% sure though.
//
// fn calculate(start: u32) -> u32 {}

fn get_counts(puzzle: &Vec<usize>, days: u32) -> VecDeque<u64> {
    let mut counts = VecDeque::from(vec![0; 9]);
    puzzle.iter().for_each(|i| counts[*i] += 1);

    for _ in 0..days {
        let new_babies = counts.pop_front().unwrap();
        counts[6] += new_babies;
        counts.push_back(new_babies);
    }

    counts
}

fn main() -> Result<()> {
    let puzzle = include_str!("../data/6.input")
        .trim()
        .split(",")
        .map(|c| c.parse::<usize>().unwrap())
        .collect_vec();

    let counts = get_counts(&puzzle, 80);
    println!("{:?}", counts.iter().sum::<u64>());

    let counts = get_counts(&puzzle, 256);
    println!("{:?}", counts.iter().sum::<u64>());

    Ok(())
}
