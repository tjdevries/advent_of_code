use anyhow::Result;
use itertools::Itertools;

// This one is just literally the distance between them accumulated,
// nothing crazy there
fn part_1(puzzle: &Vec<i32>, dest: i32) -> Search {
    Search {
        cost: puzzle.iter().fold(0, |acc, loc| i32::abs(loc - dest) + acc),
        target: dest,
    }
}

// This is a classic one in these problems.
// n * (n + 1) / 2 is the way you can do: 11 + 10 + 9 + ...
fn part_2(puzzle: &Vec<i32>, dest: i32) -> Search {
    Search {
        cost: puzzle.iter().fold(0, |acc, loc| {
            let n = i32::abs(loc - dest);
            (n * (n + 1) / 2) + acc
        }),
        target: dest,
    }
}

#[derive(Debug, Clone, Copy)]
struct Search {
    cost: i32,
    target: i32,
}

fn avg(a: i32, b: i32, offset: i32) -> i32 {
    (a + b + offset) / 2
}

fn search<F>(cost: F, puzzle: &Vec<i32>, left: &Search, right: &Search, dest: i32) -> Search
where
    F: Fn(&Vec<i32>, i32) -> Search,
{
    let target_search = cost(puzzle, dest);
    if left.target == right.target - 1 || left.target == right.target {
        // println!("{:?} -> {:?} -> {:?}", left, target_search, right);

        if left.cost < right.cost {
            return *left;
        } else {
            return *right;
        }
    }

    if left.cost <= right.cost {
        search(
            cost,
            puzzle,
            left,
            &target_search,
            avg(target_search.target, left.target, 0),
        )
    } else {
        search(
            cost,
            puzzle,
            &target_search,
            right,
            avg(target_search.target, right.target, 1),
        )
    }
}

fn main() -> Result<()> {
    let puzzle = include_str!("../data/7.input")
        .trim()
        .split(",")
        .map(|c| c.parse::<i32>().unwrap())
        .collect_vec();

    let min = puzzle.iter().min().unwrap();
    let max = puzzle.iter().max().unwrap();

    for cost in [part_1, part_2] {
        let cost_left = cost(&puzzle, *min);
        let cost_right = cost(&puzzle, *max);
        let efficient = search(cost, &puzzle, &cost_left, &cost_right, avg(*min, *max, 0));
        println!("{:?}", efficient);
    }

    // This is the way to brute force the solution
    // On my machine it wasn't even that slow.
    //
    // let mut cheapest: Option<Search> = None;
    // for num in *min..=*max {
    //     cheapest = match cheapest {
    //         Some(search) => {
    //             let new = cost(&puzzle, num);
    //             if search.cost > new.cost {
    //                 Some(new)
    //             } else {
    //                 Some(search)
    //             }
    //         }
    //         None => Some(cost(&puzzle, num)),
    //     }
    // }
    // println!("{:?}", cheapest.unwrap());

    // Also, you can use median for part 1 and mean for part 2 to help you out a lot

    Ok(())
}
