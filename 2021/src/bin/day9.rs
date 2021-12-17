use std::collections::HashSet;

use itertools::Itertools;

fn main() {
    let puzzle = include_str!("../data/9.input")
        .lines()
        .map(|l| l.chars().map(|c| c.to_digit(10).unwrap()).collect_vec())
        .collect_vec();

    let row_size = puzzle.len();
    let col_size = puzzle[0].len();

    let mut anchors = Vec::new();
    for (row, line) in puzzle.iter().enumerate() {
        line.iter().enumerate().for_each(|(col, val)| {
            if aoc::cardinal_directions(row, col, row_size, col_size)
                .into_iter()
                .all(|(x, y)| puzzle[x][y] > *val)
            {
                anchors.push((row, col))
            }
        })
    }

    println!(
        "Part 1: {:?}",
        anchors
            .iter()
            .fold(0, |acc, (x, y)| acc + puzzle[*x][*y] + 1)
    );

    let mut basins: Vec<usize> = Vec::new();
    let mut counted: HashSet<(usize, usize)> = HashSet::new();

    for (anchor_x, anchor_y) in anchors.into_iter() {
        counted.insert((anchor_x, anchor_y));

        let anchor_val = puzzle[anchor_x][anchor_y];
        let mut to_visit = aoc::cardinal_directions(anchor_x, anchor_y, row_size, col_size)
            .into_iter()
            .map(|(a, b)| (a, b, anchor_val))
            .collect_vec();

        // Count the basin base, so start at 1
        let mut current_basin_size = 1;
        while !to_visit.is_empty() {
            let (x, y, comparison_val) = to_visit.pop().unwrap();

            let visitor = (x, y);
            if counted.contains(&visitor) {
                continue;
            }

            let val = puzzle[x][y];
            if val > comparison_val && val != 9 {
                current_basin_size += 1;

                to_visit.extend(
                    aoc::cardinal_directions(x, y, row_size, col_size)
                        .into_iter()
                        .map(|(a, b)| (a, b, val)),
                );

                // Only add ones that we have counted
                counted.insert(visitor);
            }
        }

        if current_basin_size > 0 {
            basins.push(current_basin_size);
        }
    }

    println!(
        "Part 2: {:?}",
        basins.iter().sorted().rev().take(3).product::<usize>()
    );
}
