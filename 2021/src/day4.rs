use std::{collections::HashSet, str::Lines};

use itertools::Itertools;

#[derive(Debug, Clone)]
struct Board {
    /// List of sets of winning combinations.
    sets: Vec<HashSet<i32>>,
}

impl Board {
    fn new(lines: &mut Lines) -> Option<Board> {
        let mut sets: Vec<HashSet<i32>> = Vec::new();

        // Read empty line
        let empty = lines.next()?;
        if empty != "" {
            panic!("Dude, surely you messed something up");
        }

        // [
        //  [7, 13, 22, 2, 1],
        //  [3, 5, 10, 9, 8],
        //  ...
        // ]
        let rows: Vec<Vec<i32>> = lines
            .take(5)
            .map(|l| l.split_whitespace().map(|m| m.parse().unwrap()).collect())
            .collect_vec();

        // Column-wise
        for col in 0..5 {
            let mut set = HashSet::new();
            for row in 0..5 {
                set.insert(rows[row][col]);
            }

            sets.push(set);
        }

        // Row-wise
        for row in rows {
            sets.push(HashSet::from_iter(row));
        }

        // No diagonals in this mode

        Some(Board { sets })
    }

    fn turn(&mut self, m: i32) -> bool {
        let mut complete = false;
        for set in self.sets.iter_mut() {
            if set.remove(&m) {
                complete |= set.is_empty();
            }
        }

        complete
    }

    fn remaining_sum(&self) -> i32 {
        HashSet::<&i32>::from_iter(self.sets.iter().flatten())
            .into_iter()
            .sum()

        // // Alternatively:
        // let mut remaining = HashSet::new();
        //
        // for s in self.sets.iter() {
        //     remaining.extend(s);
        // }
        //
        // remaining.iter().sum()
    }
}

fn main() {
    let mut lines = include_str!("../data/4.input").lines();
    let moves = lines
        .next()
        .unwrap()
        .split(",")
        .map(|m| m.parse::<i32>().unwrap())
        .collect_vec();

    let mut boards = Vec::new();
    while let Some(board) = Board::new(&mut lines) {
        boards.push(board)
    }

    // Part 1
    {
        let mut boards = boards.clone();
        'moves: for m in &moves {
            for board in boards.iter_mut() {
                if board.turn(*m) {
                    println!("Part 1: {}", m * board.remaining_sum());
                    break 'moves;
                }
            }
        }
    }

    // Part 2
    {
        let mut last_result = 0;
        for m in &moves {
            let mut to_remove = Vec::new();
            for (idx, board) in boards.iter_mut().enumerate() {
                if board.turn(*m) {
                    last_result = m * board.remaining_sum();
                    to_remove.push(idx);
                }
            }

            // Remove boards that are complete.
            // Iterate back-to-front for indexes to be correct
            for idx in to_remove.iter().rev() {
                boards.remove(*idx);
            }
        }

        println!("Part 2: {:?}", last_result);
    }
}
