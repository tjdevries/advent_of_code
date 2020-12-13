pub fn run() {
    let mut test_1 = vec![
        1, 0, 0, 3, 1, 1, 2, 3, 1, 3, 4, 3, 1, 5, 0, 3, 2, 13, 1, 19, 1, 19, 10, 23, 1, 23, 6, 27,
        1, 6, 27, 31, 1, 13, 31, 35, 1, 13, 35, 39, 1, 39, 13, 43, 2, 43, 9, 47, 2, 6, 47, 51, 1,
        51, 9, 55, 1, 55, 9, 59, 1, 59, 6, 63, 1, 9, 63, 67, 2, 67, 10, 71, 2, 71, 13, 75, 1, 10,
        75, 79, 2, 10, 79, 83, 1, 83, 6, 87, 2, 87, 10, 91, 1, 91, 6, 95, 1, 95, 13, 99, 1, 99, 13,
        103, 2, 103, 9, 107, 2, 107, 10, 111, 1, 5, 111, 115, 2, 115, 9, 119, 1, 5, 119, 123, 1,
        123, 9, 127, 1, 127, 2, 131, 1, 5, 131, 0, 99, 2, 0, 14, 0,
    ];

    test_1[1] = 12;
    test_1[2] = 2;

    println!("{:?}", perform_opcodes(test_1));
}

const OPCODE_COMPLETE: i32 = 99;
const OPCODE_ADD: i32 = 1;
const OPCODE_MUL: i32 = 2;

fn perform_opcodes(v: Vec<i32>) -> Vec<i32> {
    let mut copy_v = v.clone();
    let mut index = 0;

    fn apply<F>(apply_to: &[i32], index: usize, f: F) -> i32
    where
        F: Fn(i32, i32) -> i32,
    {
        f(
            apply_to[apply_to[index + 1] as usize],
            apply_to[apply_to[index + 2] as usize],
        )
    }

    while index < copy_v.len() {
        match copy_v[index] {
            OPCODE_ADD => {
                let mut_index = copy_v[index + 3] as usize;
                println!(
                    "Adding! {} {}",
                    mut_index,
                    apply(&copy_v, index, |a, b| a + b)
                );
                copy_v[mut_index] = apply(&copy_v, index, |a, b| a + b);
            }
            OPCODE_MUL => {
                let mut_index = copy_v[index + 3] as usize;
                println!(
                    "Mult: {} {}",
                    mut_index,
                    apply(&copy_v, index, |a, b| a * b)
                );

                copy_v[mut_index] = apply(&copy_v, index, |a, b| a * b);
            }
            OPCODE_COMPLETE => return copy_v,
            _ => println!("Uh...???"),
        }

        index += 4;
    }

    return copy_v;
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_1() {
        let input_1 = vec![1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50];
        let expected_1 = vec![3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50];
        assert_eq!(expected_1, perform_opcodes(input_1))
    }

    #[test]
    fn test_2() {
        let input_1 = vec![1, 0, 0, 0, 99];
        let expected_1 = vec![2, 0, 0, 0, 99];
        assert_eq!(expected_1, perform_opcodes(input_1))
    }

    #[test]
    fn test_3() {
        let input_1 = vec![2, 3, 0, 3, 99];
        let expected_1 = vec![2, 3, 0, 6, 99];
        assert_eq!(expected_1, perform_opcodes(input_1))
    }

    #[test]
    fn test_4() {
        let input_1 = vec![2, 4, 4, 5, 99, 0];
        let expected_1 = vec![2, 4, 4, 5, 99, 9801];
        assert_eq!(expected_1, perform_opcodes(input_1))
    }

    #[test]
    fn test_5() {
        let input_1 = vec![1, 1, 1, 4, 99, 5, 6, 0, 99];
        let expected_1 = vec![30, 1, 1, 4, 2, 5, 6, 0, 99];
        assert_eq!(expected_1, perform_opcodes(input_1))
    }
}
