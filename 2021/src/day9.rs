use std::{collections::HashSet, ops::Sub};

use itertools::Itertools;

fn directions(x: usize, y: usize, x_bound: usize, y_bound: usize) -> Vec<(usize, usize)> {
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

fn main() {
    let puzzle = include_str!("../data/9.input")
        .lines()
        .map(|l| l.chars().map(|c| c.to_digit(10).unwrap()).collect_vec())
        .collect_vec();

    // println!("puzzle: {:?}", puzzle);

    let row_size = puzzle.len() as i32;
    let col_size = puzzle[0].len() as i32;

    let res = puzzle.iter().enumerate().fold(0, |low_row, (row, line)| {
        let row = row as i32;

        low_row
            + line.iter().enumerate().fold(0, |low_col, (col, val)| {
                let col = col as i32;

                for (row_offset, col_offset) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                    let x = row + row_offset;
                    let y = col + col_offset;
                    if x < 0 || y < 0 || x >= row_size || y >= col_size {
                        continue;
                    }

                    if puzzle[x as usize][y as usize] <= *val {
                        return low_col;
                    }
                }

                low_col + val + 1
            })
    });

    println!("Part 1: {:?}", res);

    let row_size = puzzle.len();
    let col_size = puzzle[0].len();

    let mut anchors = Vec::new();
    for (row, line) in puzzle.iter().enumerate() {
        let row = row as i32;

        'val_loop: for (col, val) in line.iter().enumerate() {
            let col = col as i32;

            for (row_offset, col_offset) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
                let x = row + row_offset;
                let y = col + col_offset;

                if x < 0 || y < 0 || x >= row_size as i32 || y >= col_size as i32 {
                    continue;
                } else if puzzle[x as usize][y as usize] <= *val {
                    continue 'val_loop;
                }
            }

            anchors.push((row as usize, col as usize))
        }
    }

    let mut counted: HashSet<(usize, usize)> = HashSet::new();
    let mut basins: Vec<usize> = Vec::new();

    for (anchor_x, anchor_y) in anchors.into_iter() {
        println!("Checking: {} {}", anchor_x, anchor_y);

        counted.insert((anchor_x, anchor_y));

        let anchor_val = puzzle[anchor_x][anchor_y];
        let mut to_visit = directions(anchor_x, anchor_y, row_size, col_size)
            .into_iter()
            .map(|(a, b)| (a, b, anchor_val))
            .collect_vec();

        let mut current_basin = 1;
        while !to_visit.is_empty() {
            let (x, y, compare) = to_visit.pop().unwrap();
            let val = puzzle[x][y];
            let visitor = (x, y);

            if counted.contains(&visitor) {
                continue;
            }

            if val == 9 {
                continue;
            }

            if val > compare {
                current_basin += 1;
                let new_to_visit = directions(x, y, row_size, col_size)
                    .into_iter()
                    .map(|(a, b)| (a, b, val))
                    .collect_vec();
                to_visit.extend_from_slice(&new_to_visit);

                // Only add ones that we have counted
                counted.insert(visitor);
            }
        }

        if current_basin > 0 {
            basins.push(current_basin);
        }
    }

    println!(
        "Basins: {:?} {:?}",
        basins,
        basins.iter().sorted().rev().take(3).product::<usize>()
    );
    //     let row = row as i32;
    //
    //     low_row
    //         + line.iter().enumerate().fold(0, |low_col, (col, val)| {
    //             let col = col as i32;
    //
    //             for (row_offset, col_offset) in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
    //                 let x = row + row_offset;
    //                 let y = col + col_offset;
    //                 if x < 0 || y < 0 || x >= row_size || y >= col_size {
    //                     continue;
    //                 }
    //
    //                 if puzzle[x as usize][y as usize] <= *val {
    //                     return low_col;
    //                 }
    //             }
    //
    //             low_col + val + 1
    //         })
    // });
}
