use std::collections::VecDeque;

use anyhow::Result;

fn main() -> Result<()> {
    let puzzle = aoc::read_one_line("./data/6.input", ",")?;

    println!("Part 1: {:?}", get_counts(&puzzle, 80));
    println!("Part 2: {:?}", get_counts(&puzzle, 256));

    Ok(())
}

fn get_counts(puzzle: &Vec<usize>, days: u32) -> u64 {
    // [0, 0, 0, 0, 0, 0, 0, 0, 0]
    let mut counts = VecDeque::from(vec![0; 9]);

    // Add initial condition
    // [5, 2, 1, 0, 0, 3, 0, 0, 0]
    puzzle.iter().for_each(|i| counts[*i] += 1);

    // Run simulation
    (0..days).for_each(|_| {
        let new_babies = counts.pop_front().unwrap();
        counts[6] += new_babies;
        counts.push_back(new_babies);
    });

    // Sum
    counts.iter().sum()
}
