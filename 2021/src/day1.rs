fn main() {
    let part1 = include_str!("day1.input")
        .split("\n")
        .filter_map(|line| line.parse::<usize>().ok())
        .collect::<Vec<usize>>()
        .windows(2)
        .fold(0, |acc, win| if win[0] < win[1] { acc + 1 } else { acc });

    println!("Part 1: {}", part1);

    let part2 = include_str!("day1.input")
        .split("\n")
        .filter_map(|line| line.parse::<usize>().ok())
        .collect::<Vec<usize>>()
        .windows(4)
        .fold(0, |acc, win| {
            if win[0..3].iter().sum::<usize>() < win[1..4].iter().sum::<usize>() {
                acc + 1
            } else {
                acc
            }
        });

    println!("Part 2: {:?}", part2);
}
