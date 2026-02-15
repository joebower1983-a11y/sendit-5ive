/**
 * SendIt 5IVE SDK — Account Types & Instruction Parameter Interfaces
 * Auto-derived from the 31 compiled .v modules
 */

import type { PublicKey } from "@solana/web3.js";

// ---------------------------------------------------------------------------
// Utility
// ---------------------------------------------------------------------------

/** Accepts a PublicKey or base58 string wherever an address is needed. */
export type Address = PublicKey | string;

// ---------------------------------------------------------------------------
// Account Structs (on-chain state shapes)
// ---------------------------------------------------------------------------

// -- achievements.v --
export interface AchievementConfig {
  totalUsers: bigint;
  authority: PublicKey;
  bump: number;
}
export interface UserAchievements {
  user: PublicKey;
  badges: bigint;
  tradeCount: bigint;
  totalVolume: bigint;
  tokensLaunched: bigint;
  earliestHoldStart: bigint;
  createdAt: bigint;
  bump: number;
}

// -- airdrops.v --
export interface AirdropCampaign {
  campaignId: bigint;
  tokenMint: PublicKey;
  creator: PublicKey;
  vault: PublicKey;
  totalAmount: bigint;
  claimedCount: bigint;
  maxRecipients: bigint;
  snapshotSlot: bigint;
  deadline: bigint;
  isActive: number;
  bump: number;
  vaultBump: number;
}
export interface AirdropClaim {
  campaign: PublicKey;
  claimant: PublicKey;
  amount: bigint;
  claimedAt: bigint;
  bump: number;
}

// -- analytics.v --
export interface TokenAnalytics {
  tokenMint: PublicKey;
  totalVolume: bigint;
  totalTrades: bigint;
  holderCount: bigint;
  lastUpdateSlot: bigint;
  lastSnapshotTs: bigint;
  hourlyVolumeCurrent: bigint;
  whaleTxCount: bigint;
  lastWhaleTrader: PublicKey;
  lastWhaleAmount: bigint;
  lastWhaleIsBuy: number;
  lastWhaleTs: bigint;
  bump: number;
}
export interface WhaleTracker {
  tokenMint: PublicKey;
  holderCount: number;
  top1Wallet: PublicKey;
  top1Balance: bigint;
  top2Wallet: PublicKey;
  top2Balance: bigint;
  top3Wallet: PublicKey;
  top3Balance: bigint;
  top4Wallet: PublicKey;
  top4Balance: bigint;
  top5Wallet: PublicKey;
  top5Balance: bigint;
  bump: number;
}

// -- bridge.v --
export interface BridgeConfig {
  authority: PublicKey;
  wormholeProgram: PublicKey;
  wormholeBridge: PublicKey;
  feeCollector: PublicKey;
  totalBridged: bigint;
  totalRequests: bigint;
  paused: number;
  defaultFeeBps: bigint;
  defaultMinAmount: bigint;
  bump: number;
}
export interface BridgeRequest {
  user: PublicKey;
  tokenMint: PublicKey;
  amount: bigint;
  feeAmount: bigint;
  netAmount: bigint;
  destinationChain: bigint;
  status: number;
  createdAt: bigint;
  wormholeSequence: bigint;
  nonce: bigint;
  bump: number;
}

// -- content_claims.v --
export interface ContentClaim {
  tokenMint: PublicKey;
  originalCreator: PublicKey;
  claimedBy: PublicKey;
  claimStatus: number;
  claimedAt: bigint;
  feeRedirectBps: bigint;
  bump: number;
}
export interface ClaimVerification {
  tokenMint: PublicKey;
  claimant: PublicKey;
  submittedAt: bigint;
  resolved: number;
  bump: number;
}

// -- copy_trading.v --
export interface TraderProfile {
  trader: PublicKey;
  totalPnl: bigint;
  totalTrades: bigint;
  winningTrades: bigint;
  followersCount: bigint;
  createdAt: bigint;
  lastTradeAt: bigint;
  active: number;
  bump: number;
}
export interface CopyPosition {
  follower: PublicKey;
  leader: PublicKey;
  maxAllocation: bigint;
  usedAllocation: bigint;
  active: number;
  createdAt: bigint;
  totalCopiedTrades: bigint;
  copyPnl: bigint;
  bump: number;
}

// -- creator_dashboard.v --
export interface CreatorAnalytics {
  creator: PublicKey;
  totalLaunches: bigint;
  totalVolumeGenerated: bigint;
  totalFeesEarned: bigint;
  totalHoldersAcrossTokens: bigint;
  bestPerformingToken: PublicKey;
  avgGraduationTime: bigint;
  bump: number;
}
export interface TokenAnalyticsSnapshot {
  tokenMint: PublicKey;
  currentSlot: bigint;
  latestHourlyVolume: bigint;
  latestHolderGrowth: bigint;
  bump: number;
}

// -- custom_pages.v --
export interface CustomPage {
  tokenLaunch: PublicKey;
  mint: PublicKey;
  creator: PublicKey;
  tier: number;
  contentHash: PublicKey;
  lastUpdated: bigint;
  feePaid: bigint;
  bump: number;
}

// -- daily_rewards.v --
export interface DailyRewardsConfig {
  authority: PublicKey;
  pointsPerCheckin: bigint;
  streakMultiplier: bigint;
  pointsPerTradeSol: bigint;
  totalCheckins: bigint;
  bump: number;
}
export interface UserDailyRewards {
  user: PublicKey;
  currentStreak: bigint;
  longestStreak: bigint;
  lastCheckinDay: bigint;
  totalPoints: bigint;
  tier: number;
  totalRedeemed: bigint;
  bump: number;
}

// -- embeddable_widgets.v --
export interface WidgetConfig {
  tokenMint: PublicKey;
  creator: PublicKey;
  widgetType: number;
  theme: number;
  customColorR: number;
  customColorG: number;
  customColorB: number;
  showPrice: number;
  showVolume: number;
  showHolders: number;
  showMarketCap: number;
  enabled: number;
  views: bigint;
  bump: number;
}

// -- fee_splitting.v --
export interface FeeConfig {
  tokenMint: PublicKey;
  creator: PublicKey;
  splitCount: number;
  split1Recipient: PublicKey;
  split1Bps: bigint;
  split2Recipient: PublicKey;
  split2Bps: bigint;
  split3Recipient: PublicKey;
  split3Bps: bigint;
  split4Recipient: PublicKey;
  split4Bps: bigint;
  split5Recipient: PublicKey;
  split5Bps: bigint;
  totalDistributed: bigint;
  hasDistributed: number;
  allowUpdate: number;
  bump: number;
}
export interface UserFeeClaim {
  recipient: PublicKey;
  tokenMint: PublicKey;
  totalAllocated: bigint;
  totalClaimed: bigint;
  bump: number;
}

// -- fund_tokens.v --
export interface FundConfig {
  nameHash: PublicKey;
  creator: PublicKey;
  shareMint: PublicKey;
  totalDepositsSol: bigint;
  managementFeeBps: bigint;
  active: number;
  createdAt: bigint;
  numTokens: bigint;
  weightSum: bigint;
  bump: number;
  shareMintBump: number;
}
export interface UserFundPosition {
  user: PublicKey;
  fund: PublicKey;
  sharesHeld: bigint;
  totalDepositedSol: bigint;
  totalRedeemedSol: bigint;
  firstDepositAt: bigint;
  bump: number;
}

// -- holder_rewards.v --
export interface RewardPool {
  mint: PublicKey;
  authority: PublicKey;
  rewardPerTokenStored: bigint;
  totalSupplyEligible: bigint;
  lastUpdateTs: bigint;
  minHoldSeconds: bigint;
  rewardFeeBps: bigint;
  bump: number;
  vaultBump: number;
}
export interface UserRewardState {
  user: PublicKey;
  mint: PublicKey;
  rewardPerTokenPaid: bigint;
  rewardsEarned: bigint;
  balance: bigint;
  firstHoldTs: bigint;
  autoCompound: number;
  bump: number;
}

// -- lending.v --
export interface LendingPool {
  collateralMint: PublicKey;
  authority: PublicKey;
  totalDeposited: bigint;
  totalBorrowed: bigint;
  interestRateBps: bigint;
  ltvRatio: bigint;
  liquidationThresholdBps: bigint;
  lastUpdate: bigint;
  graduated: number;
  bump: number;
}
export interface UserLendPosition {
  user: PublicKey;
  collateralToken: PublicKey;
  deposited: bigint;
  borrowed: bigint;
  collateralAmount: bigint;
  lastInterestUpdate: bigint;
  interestOwed: bigint;
  bump: number;
}

// -- limit_orders.v --
export interface LimitOrder {
  owner: PublicKey;
  token: PublicKey;
  side: number;
  priceTarget: bigint;
  amount: bigint;
  status: number;
  createdAt: bigint;
  orderIndex: bigint;
  bump: number;
}
export interface UserOrderCounter {
  activeCount: bigint;
  nextIndex: bigint;
  bump: number;
}

// -- live_chat.v --
export interface ChatRoom {
  tokenMint: PublicKey;
  creator: PublicKey;
  authority: PublicKey;
  messageCount: bigint;
  isActive: number;
  slowmodeSeconds: bigint;
  bump: number;
}
export interface LiveMessage {
  chatRoom: PublicKey;
  index: bigint;
  author: PublicKey;
  textHash: PublicKey;
  timestamp: bigint;
  tipsReceived: bigint;
  bump: number;
}
export interface UserChatState {
  chatRoom: PublicKey;
  user: PublicKey;
  lastMessageTs: bigint;
  bump: number;
}

// -- main.v (staking) --
export interface StakePool {
  mint: PublicKey;
  creator: PublicKey;
  vault: PublicKey;
  totalStaked: bigint;
  rewardRate: bigint;
  rewardPerTokenStored: bigint;
  lastUpdate: bigint;
  graduated: number;
  bump: number;
  vaultBump: number;
}
export interface UserStake {
  user: PublicKey;
  mint: PublicKey;
  pool: PublicKey;
  amount: bigint;
  startTime: bigint;
  rewardsEarned: bigint;
  rewardPerTokenPaid: bigint;
  bump: number;
}

// -- perps.v --
export interface PerpMarket {
  bump: number;
  authority: PublicKey;
  tokenMint: PublicKey;
  collateralMint: PublicKey;
  raydiumPool: PublicKey;
  solforgeVault: PublicKey;
  insuranceFundKey: PublicKey;
  collateralVault: PublicKey;
  orderBookKey: PublicKey;
  maxLeverage: bigint;
  maintenanceMargin: bigint;
  liquidationFee: bigint;
  makerFee: bigint;
  takerFee: bigint;
  fundingInterval: bigint;
  maxOpenInterest: bigint;
  maxPositionSize: bigint;
  markPrice: bigint;
  indexPrice: bigint;
  longOpenInterest: bigint;
  shortOpenInterest: bigint;
  cumulFundingLong: bigint;
  cumulFundingLongSign: number;
  cumulFundingShort: bigint;
  cumulFundingShortSign: number;
  lastFundingTime: bigint;
  paused: number;
  createdAt: bigint;
  twapLastPrice: bigint;
  twapLastTime: bigint;
  twapSum: bigint;
  twapCount: bigint;
}
export interface OrderBook {
  bump: number;
  market: PublicKey;
  nextOrderId: bigint;
  bidCount: bigint;
  askCount: bigint;
}
export interface OrderEntry {
  orderId: bigint;
  owner: PublicKey;
  price: bigint;
  size: bigint;
  remaining: bigint;
  side: number;
  orderType: number;
  timestamp: bigint;
  marginAccount: PublicKey;
  book: PublicKey;
  active: number;
}
export interface UserMarginAccount {
  bump: number;
  owner: PublicKey;
  collateral: bigint;
  openPositions: bigint;
  realizedPnl: bigint;
  realizedPnlSign: number;
  createdAt: bigint;
}
export interface Position {
  bump: number;
  market: PublicKey;
  owner: PublicKey;
  marginAccount: PublicKey;
  side: number;
  size: bigint;
  entryPrice: bigint;
  collateral: bigint;
  leverage: bigint;
  lastCumulFunding: bigint;
  lastCumulFundingSign: number;
  pendingFunding: bigint;
  pendingFundingSign: number;
  openedAt: bigint;
  updatedAt: bigint;
  active: number;
}
export interface InsuranceFund {
  bump: number;
  market: PublicKey;
  vault: PublicKey;
  balance: bigint;
  totalPayouts: bigint;
  totalDeposits: bigint;
}

// -- points_system.v --
export interface PointsConfig {
  authority: PublicKey;
  pointsPerTrade: bigint;
  pointsPerLaunch: bigint;
  pointsPerReferral: bigint;
  pointsPerHoldDay: bigint;
  seasonId: bigint;
  actionCooldown: bigint;
  maxDailyPoints: bigint;
  paused: number;
  bump: number;
}
export interface UserPoints {
  user: PublicKey;
  seasonId: bigint;
  totalPoints: bigint;
  availablePoints: bigint;
  level: bigint;
  lastActionTs: bigint;
  streakDays: bigint;
  lastActionDay: bigint;
  dailyPointsEarned: bigint;
  dailyResetDay: bigint;
  bump: number;
}

// -- prediction.v --
export interface PredictionMarket {
  tokenA: PublicKey;
  tokenB: PublicKey;
  creator: PublicKey;
  totalPoolA: bigint;
  totalPoolB: bigint;
  deadline: bigint;
  resolved: number;
  winner: number;
  marketIndex: bigint;
}
export interface UserBet {
  user: PublicKey;
  market: PublicKey;
  side: number;
  amount: bigint;
  claimed: number;
}

// -- premium.v --
export interface PremiumConfig {
  authority: PublicKey;
  treasury: PublicKey;
  promotedPricePerHour: bigint;
  featuredPricePerHour: bigint;
  spotlightPricePerHour: bigint;
  bump: number;
}
export interface PremiumListing {
  tokenMint: PublicKey;
  purchaser: PublicKey;
  tier: number;
  startTime: bigint;
  duration: bigint;
  amountPaid: bigint;
  active: number;
  bump: number;
}

// -- price_alerts.v --
export interface AlertSubscription {
  owner: PublicKey;
  tokenMint: PublicKey;
  targetPrice: bigint;
  direction: number;
  active: number;
  createdAt: bigint;
  triggeredAt: bigint;
  alertId: bigint;
  bump: number;
}

// -- raffle.v --
export interface Raffle {
  tokenLaunch: PublicKey;
  mint: PublicKey;
  creator: PublicKey;
  ticketPrice: bigint;
  maxTickets: bigint;
  soldTickets: bigint;
  winnerCount: bigint;
  drawTime: bigint;
  randomnessSeed: bigint;
  tokenAllocation: bigint;
  tokensPerWinner: bigint;
  drawn: number;
  bump: number;
}
export interface RaffleTicket {
  raffle: PublicKey;
  owner: PublicKey;
  ticketIndex: bigint;
  isWinner: number;
  claimed: number;
  bump: number;
}

// -- referral.v --
export interface ReferralConfig {
  authority: PublicKey;
  referralFeeBps: bigint;
  treasury: PublicKey;
  bump: number;
}
export interface ReferralAccount {
  user: PublicKey;
  referrer: PublicKey;
  totalReferred: bigint;
  totalEarned: bigint;
  claimable: bigint;
  registeredAt: bigint;
  bump: number;
}

// -- reputation.v --
export interface ReputationConfig {
  authority: PublicKey;
  oracleAuthority: PublicKey;
  minScoreToLaunch: number;
  minScorePremiumLaunch: number;
  strictVestingThreshold: number;
  feeDiscountBronzeBps: bigint;
  feeDiscountSilverBps: bigint;
  feeDiscountGoldBps: bigint;
  feeDiscountPlatinumBps: bigint;
  bump: number;
}
export interface ReputationAttestation {
  wallet: PublicKey;
  fairscore: number;
  tier: number;
  lastUpdated: bigint;
  attestedBy: PublicKey;
  bump: number;
}

// -- seasons.v --
export interface Season {
  authority: PublicKey;
  seasonNumber: bigint;
  startTime: bigint;
  endTime: bigint;
  totalParticipants: bigint;
  prizePoolLamports: bigint;
  isActive: number;
  isFinalized: number;
  bump: number;
}
export interface SeasonPass {
  season: PublicKey;
  user: PublicKey;
  xp: bigint;
  level: bigint;
  tradesCount: bigint;
  volume: bigint;
  achievementsUnlocked: bigint;
  rewardsClaimedMask: bigint;
  joinedAt: bigint;
  bump: number;
}
export interface SeasonReward {
  season: PublicKey;
  level: bigint;
  minXp: bigint;
  rewardType: number;
  rewardAmount: bigint;
  bump: number;
}

// -- share_cards.v --
export interface ShareCard {
  currentPrice: bigint;
  marketCap: bigint;
  volume24h: bigint;
  holderCount: bigint;
  creator: PublicKey;
  migrationProgressBps: bigint;
  lastUpdated: bigint;
  tokenMint: PublicKey;
  bump: number;
}

// -- social_launch.v --
export interface SocialLaunchConfig {
  authority: PublicKey;
  verifierAuthority: PublicKey;
  requireVerification: number;
  defaultCurveType: number;
  defaultCreatorFeeBps: bigint;
  verificationGracePeriod: bigint;
  totalSocialLaunches: bigint;
  bump: number;
}
export interface SocialLaunchRecord {
  creator: PublicKey;
  mint: PublicKey;
  tweetIdHash: PublicKey;
  authorHandleHash: PublicKey;
  verified: number;
  createdAt: bigint;
  verifiedAt: bigint;
  tradingStartsAt: bigint;
  creatorFeeBps: bigint;
  curveType: number;
  bump: number;
}
export interface TweetVerification {
  tweetIdHash: PublicKey;
  authorHandleHash: PublicKey;
  verified: number;
  verifiedBy: PublicKey;
  verifiedAt: bigint;
  associatedMint: PublicKey;
  bump: number;
}

// -- stable_pairs.v --
export interface StablePairConfig {
  tokenMint: PublicKey;
  stableMint: PublicKey;
  poolTokenReserve: bigint;
  poolStableReserve: bigint;
  feeBps: bigint;
  creator: PublicKey;
  totalLpShares: bigint;
  paused: number;
  bump: number;
  tokenVaultBump: number;
  stableVaultBump: number;
}
export interface LPPosition {
  pair: PublicKey;
  owner: PublicKey;
  lpShares: bigint;
  bump: number;
}

// -- token_chat.v --
export interface ChatState {
  tokenMint: PublicKey;
  nextIndex: bigint;
  bump: number;
}
export interface ChatMessage {
  tokenMint: PublicKey;
  index: bigint;
  author: PublicKey;
  textHash: PublicKey;
  timestamp: bigint;
  likes: bigint;
  deleted: number;
  bump: number;
}

// -- token_videos.v --
export interface TokenVideo {
  creator: PublicKey;
  videoUrlHash: PublicKey;
  thumbnailUrlHash: PublicKey;
  descriptionHash: PublicKey;
  upvotes: bigint;
  downvotes: bigint;
  postedAt: bigint;
  tokenMint: PublicKey;
  bump: number;
}
export interface UserVideoVote {
  user: PublicKey;
  tokenMint: PublicKey;
  isUpvote: number;
  bump: number;
}

// -- voting.v --
export interface Proposal {
  proposalId: bigint;
  tokenMint: PublicKey;
  creator: PublicKey;
  optionCount: number;
  option0Votes: bigint;
  option1Votes: bigint;
  option2Votes: bigint;
  option3Votes: bigint;
  startTime: bigint;
  endTime: bigint;
  quorum: bigint;
  totalVotes: bigint;
  status: number;
  bump: number;
}
export interface UserVote {
  proposal: PublicKey;
  voter: PublicKey;
  optionIndex: number;
  weight: bigint;
  timestamp: bigint;
  bump: number;
}
