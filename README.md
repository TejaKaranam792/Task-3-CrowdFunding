🏗️ Crowdfunding Smart Contract (With Refunds)

A secure, deadline-based crowdfunding smart contract written in Solidity that demonstrates correct state-machine design, safe fund handling, and refund logic.

This project focuses on correctness, safety, and edge-case handling, following best practices from audited crowdfunding protocols.

📌 Features

⏳ Deadline-based fundraising

🔁 Refunds enabled if funding goal is not met

💰 Creator withdrawal only if goal is met

🚫 No stuck funds

🧠 Explicit state machine

🔒 Re-entrancy-safe fund flows

📦 Clear accounting of contributions

🧠 Contract Design

The contract uses an explicit state machine to ensure safe transitions:

Active → Successful → Withdrawn
Active → Failed → Refunded

States

Active: Campaign is live and accepting funds

Successful: Goal reached after deadline

Failed: Goal not reached after deadline

State transitions are strictly controlled to prevent invalid fund access.

🔧 Core Functions
contribute()

Accepts ETH contributions

Allowed only before the deadline

Tracks individual contributions

finalize()

Callable after deadline

Determines success or failure

Locks the campaign outcome

withdraw()

Callable only by creator

Allowed only if goal is met

Transfers total raised amount safely

refund()

Callable by contributors

Allowed only if goal is NOT met

Prevents double refunds

🛡️ Security Considerations

✅ Checks-Effects-Interactions pattern

✅ No re-entrancy vulnerabilities

✅ Strict access control

✅ No ETH locked permanently

✅ Deadline manipulation awareness

✅ Single-execution finalization

🧪 Testing Strategy

The contract is designed to be tested for:

Contribution tracking accuracy

Deadline enforcement

Refund correctness

Withdrawal restrictions

State transition validity

Double-spend prevention

(Tests can be written using Foundry or Hardhat.)

📚 References

Solidity Docs — block.timestamp

ConsenSys Smart Contract Best Practices

Crowdfunding protocol audit reports

🚀 How to Run
# Compile
forge build

# Test
forge test

🧩 Learning Outcomes

This project demonstrates:

Proper Solidity state machine modeling

Secure ETH flow handling

Real-world refund logic

Production-grade crowdfunding patterns

📄 License

MIT

👨‍💻 Author

Teja Karanam
Solidity Developer | Web3 Builder  ## Foundry

