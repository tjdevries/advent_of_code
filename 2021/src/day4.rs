use std::{collections::HashSet, str::Lines};

use itertools::Itertools;

#[derive(Debug, Clone)]
struct Board {
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

        let rows: Vec<Vec<i32>> = lines
            .take(5)
            .map(|l| l.split_whitespace().map(|m| m.parse().unwrap()).collect())
            .collect_vec();

        for row in &rows {
            sets.push(HashSet::from_iter(row.iter().cloned()));
        }

        for col in 0..5 {
            let mut set = HashSet::new();
            for row in 0..5 {
                set.insert(rows[row][col]);
            }

            sets.push(set);
        }

        Some(Board { sets })
    }

    fn turn(&mut self, m: i32) -> bool {
        let mut complete = false;
        for set in self.sets.iter_mut() {
            if set.remove(&m) {
                complete |= set.is_empty();
            }
        }

        return complete;
    }

    fn remaining_sum(&self) -> i32 {
        let mut remaining = HashSet::new();

        for s in self.sets.iter() {
            remaining.extend(s.iter());
        }

        remaining.iter().sum()
    }
}

fn main() {
    let puzzle = include_str!("../data/4.input");
    let mut lines = puzzle.lines();
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

    let mut first_boards = boards.clone();
    'moves: for m in &moves {
        for board in first_boards.iter_mut() {
            if board.turn(*m) {
                println!("Part 1: {}", m * board.remaining_sum());
                break 'moves;
            }
        }
    }

    let mut last_result = 0;
    for m in &moves {
        let mut to_remove = Vec::new();
        for (idx, board) in boards.iter_mut().enumerate() {
            if board.turn(*m) {
                last_result = m * board.remaining_sum();
                to_remove.push(idx);
            }
        }

        for idx in to_remove.iter().rev() {
            boards.remove(*idx);
        }
    }

    println!("Last Winner: {:?}", last_result);
}
