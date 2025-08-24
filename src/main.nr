global MAX_VOTERS: u32 = 100;
global VOTE_YES: Field =  1;
global VOTE_NO: Field = 2;

fn main(
    private_voter_id: Field, 
    private_vote_choice: Field, 
    poll_unit: pub Field,
    mut previous_records: VoteRecords,
)-> pub VoteRecords{
    let voter = Voter::new(private_voter_id, private_vote_choice, poll_unit);
    process_vote(voter.voter_id, voter.vote_choice, voter.poll_unit, previous_records)
}

fn validate_vote_choice(vote_choice: Field) -> bool {
    if vote_choice == VOTE_NO {
        true
    } else if vote_choice == VOTE_YES {
        true
    } else {
        false
    }
}

fn add_vote (voter:Voter, mut vote_records: VoteRecords)-> VoteRecords{
    // Check if we've reached maximum voters
    assert(vote_records.count < MAX_VOTERS, "Maximum voter limit reached");
    
    let mut has_voted = false;
    for i in 0..MAX_VOTERS{
        if vote_records.voter_ids[i] == voter.voter_id{
            has_voted = true;
        }
    }
    assert(!has_voted, "This voter has voted already");
    vote_records.voter_ids[vote_records.count] = voter.voter_id;
    vote_records.poll_units[vote_records.count] = voter.poll_unit;
    vote_records.count += 1;
    vote_records
}

// Voter id and vote choice can be the 2 different things, poll units can be the same
struct Voter {
    voter_id: Field,
    vote_choice: Field,
    pub poll_unit: Field,
}

impl Voter {
    fn new(voter_id: Field, vote_choice: Field, poll_unit: Field,) -> Voter {
        assert(validate_vote_choice(vote_choice), "Invalid vote choice");
        Voter{
            voter_id: voter_id,
            vote_choice: vote_choice,
            poll_unit: poll_unit
        }
    }
}

struct VoteRecords {
    voter_ids: [Field;MAX_VOTERS],
    poll_units: [Field;MAX_VOTERS],
    count: u32
}

impl VoteRecords{
    fn new()-> VoteRecords{
        VoteRecords{
            voter_ids: [0;MAX_VOTERS],
            poll_units: [0;MAX_VOTERS],
            count: 0
        }
    }
}

fn process_vote(voter_id: Field, vote_choice: Field, poll_unit: Field, mut vote_records: VoteRecords) -> VoteRecords{
    let voter = Voter::new(voter_id, vote_choice, poll_unit);
    add_vote(voter, vote_records)
}

#[test]
fn test_double_voting() {
    // THIS TEST IS SUPPOSED TO FAIL
    let mut records = VoteRecords::new();
    records = main(1, VOTE_NO, 12, records);
    records = main(1, VOTE_NO, 12, records);
}

#[test]
fn test_different_voters_voting() {
    let mut records = VoteRecords::new();
    records = main(1, VOTE_NO, 12, records);
    records = main(2, VOTE_NO, 12, records);
}

#[test]
fn test_max_voters_limit() {
    let mut records = VoteRecords::new();
    // Test adding exactly MAX_VOTERS votes (should succeed)
    for i in 1..=MAX_VOTERS as u32{
        records = main(i as Field, VOTE_YES, 12, records);
    };
    
    // Try to add one more vote (should fail with maximum voter limit reached)
    // This test will fail if the MAX_VOTERS check doesn't work
    // UNCOMMENT TO FAIL
    // records = process_vote((MAX_VOTERS + 1) as Field, VOTE_NO, 12, records);
}

