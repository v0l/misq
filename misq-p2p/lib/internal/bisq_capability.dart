/// More info https://github.com/bisq-network/bisq/blob/3303b90e485301b8dd348cf91fc14c0415095a6d/common/src/main/java/bisq/common/app/Capability.java
///
enum BisqCapability {
  @deprecated
  TradeStatistics, // Not required anymore as no old clients out there not having that support
  @deprecated
  TradeStatistics2, // Not required anymore as no old clients out there not having that support
  @deprecated
  AccountAgeWitness, // Not required anymore as no old clients out there not having that support
  SeedNode, // Node is a seed node
  DAOFullNode, // DAO full node can deliver BSQ blocks
  @deprecated
  Proposal, // Not required anymore as no old clients out there not having that support
  @deprecated
  BlindVote, // Not required anymore as no old clients out there not having that support
  @deprecated
  AckMsg, // Not required anymore as no old clients out there not having that support
  @deprecated
  DAOState, // Not required anymore as no old clients out there not having that support
  RecieveBSQBlock, // Signaling that node which wants to receive BSQ blocks (DAO lite node)
  BundleOfEnvelopes, // Supports bundling of messages if many messages are sent in short interval
  SignedAccountAgeWitness, // Supports the signed account age witness feature
  Mediation, // Supports mediation feature
}

const DefaultBisqCapability = [
  BisqCapability.TradeStatistics,
  BisqCapability.TradeStatistics2,
  BisqCapability.AccountAgeWitness,
  BisqCapability.Proposal,
  BisqCapability.BlindVote,
  BisqCapability.AckMsg,
  BisqCapability.DAOState,
  BisqCapability.RecieveBSQBlock,
  BisqCapability.BundleOfEnvelopes,
  BisqCapability.Mediation,
];
