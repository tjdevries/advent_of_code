use std::collections::HashSet;

use itertools::Itertools;

fn step(state: &mut Vec<Vec<u32>>) -> usize {
    let mut flashed = HashSet::new();

    let rows = state.len();
    let cols = state[0].len();

    for x in 0..rows {
        for y in 0..cols {
            let val = state[x][y];

            if val >= 9 {
                flashed.insert((x as i32, y as i32));
            }

            state[x][y] += 1;
        }
    }

    for (x, y) in flashed.clone().iter() {
        flash(state, &mut flashed, *x as i32, *y as i32);
    }

    for (x, y) in flashed.iter() {
        state[*x as usize][*y as usize] = 0;
    }

    flashed.len()
}

fn flash(state: &mut Vec<Vec<u32>>, flashed: &mut HashSet<(i32, i32)>, x: i32, y: i32) {
    let rows = state.len() as i32;
    let cols = state[0].len() as i32;

    for new_x in [x - 1, x, x + 1] {
        for new_y in [y - 1, y, y + 1] {
            if new_x == x && new_y == y {
                continue;
            }

            if new_x >= rows || new_x < 0 || new_y >= cols || new_y < 0 {
                continue;
            }

            if flashed.contains(&(new_x, new_y)) {
                continue;
            }

            state[new_x as usize][new_y as usize] += 1;
            if state[new_x as usize][new_y as usize] > 9 {
                flashed.insert((new_x, new_y));
                flash(state, flashed, new_x, new_y);
            }
        }
    }
}

fn main() {
    let mut state = include_str!("../../data/11.input")
        .lines()
        .map(|l| l.chars().map(|c| c.to_digit(10).unwrap()).collect_vec())
        .collect_vec();

    println!(
        "Part 1: {}",
        (0..100).fold(0, |acc, _| acc + step(&mut state))
    );

    let mut state = include_str!("../../data/11.input")
        .lines()
        .map(|l| l.chars().map(|c| c.to_digit(10).unwrap()).collect_vec())
        .collect_vec();

    println!(
        "Part 2: {}",
        (0..10000).find(|_| 100 == step(&mut state)).unwrap() + 1
    );
}
