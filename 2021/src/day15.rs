use std::{cmp::Reverse, collections::BinaryHeap};

use anyhow::Result;
use aoc::cardinal_directions;
use itertools::Itertools;

#[derive(PartialEq, Eq, Debug)]
struct Cost {
    cost: u32,
    x: usize,
    y: usize,
}

impl PartialOrd for Cost {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cost.partial_cmp(&other.cost)?.reverse())
    }
}

impl Ord for Cost {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.cost.cmp(&other.cost).reverse()
    }
}

fn find_shortest_path(puzzle: &Vec<Vec<u32>>) -> u32 {
    let size = puzzle.len();
    let mut costs = vec![vec![u32::MAX; size]; size];
    costs[0][0] = 0;

    let mut count = 0;
    let mut spots_to_check = BinaryHeap::new();
    spots_to_check.push(Cost {
        cost: 0,
        x: 0,
        y: 0,
    });

    while !spots_to_check.is_empty() {
        count += 1;

        let pos = spots_to_check.pop().unwrap();

        let prev_cost = pos.cost;
        for (x, y) in cardinal_directions(pos.x, pos.y, size, size) {
            if x == 0 && y == 0 {
                continue;
            }

            let new_cost = puzzle[x][y] + prev_cost;
            if costs[x][y] > new_cost {
                costs[x][y] = new_cost;
                spots_to_check.push(Cost {
                    cost: new_cost,
                    x,
                    y,
                })
            }
        }

        if (pos.x, pos.y) == (size - 1, size - 1) {
            break;
        }
    }

    costs[size - 1][size - 1]
}

fn main() -> Result<()> {
    let puzzle = aoc::read_vec_per_line("./data/15.input", |c| char::to_digit(c, 10))?;

    // 40 -> 388
    println!("Part 1 (solve): {:?}", find_shortest_path(&puzzle));

    let size = puzzle.len();
    let mut new_puzzle: Vec<Vec<u32>> = vec![vec![0; size * 5]; size * 5];

    (0..5).cartesian_product(0..5).for_each(|(x_mul, y_mul)| {
        (0..size).cartesian_product(0..size).for_each(|(x, y)| {
            let new_x = x_mul * size + x;
            let new_y = y_mul * size + y;
            let val = ((puzzle[x][y] + x_mul as u32 + y_mul as u32 - 1) % 9) + 1;

            new_puzzle[new_x][new_y] = val;

            // 1 - 9
            // 9 -> 1
            // 8 + 3 -> 11 - 2
        });
    });

    // 315 -> ???
    println!("Part 2 (solve): {:?}", find_shortest_path(&new_puzzle));

    println!(
        "{:?}",
        new_puzzle[0]
            .iter()
            .map(|c| c.to_string())
            .collect::<String>()
    );

    Ok(())
}
