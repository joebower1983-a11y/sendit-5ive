/**
 * SendIt 5IVE SDK
 *
 * Full TypeScript client wrapping all 31 compiled modules.
 *
 * @example
 * ```ts
 * import { SenditSDK } from "./src/index.js";
 * import { Connection, Keypair, PublicKey } from "@solana/web3.js";
 *
 * const sdk = new SenditSDK({
 *   connection: new Connection("https://api.devnet.solana.com", "confirmed"),
 *   payer: Keypair.generate(),
 *   programId: new PublicKey("YOUR_PROGRAM_ID"),
 * });
 *
 * const sig = await sdk.staking.createStakePool(
 *   { stakePool, creator, mint, vault },
 *   { rewardRate: 1000 },
 * );
 * ```
 */

import { ProgramHandle, type SenditSDKConfig } from "./base.js";

// Module clients
import { AchievementsClient } from "./modules/achievements.js";
import { AirdropsClient } from "./modules/airdrops.js";
import { AnalyticsClient } from "./modules/analytics.js";
import { BridgeClient } from "./modules/bridge.js";
import { ContentClaimsClient } from "./modules/content-claims.js";
import { CopyTradingClient } from "./modules/copy-trading.js";
import { CreatorDashboardClient } from "./modules/creator-dashboard.js";
import { CustomPagesClient } from "./modules/custom-pages.js";
import { DailyRewardsClient } from "./modules/daily-rewards.js";
import { EmbeddableWidgetsClient } from "./modules/embeddable-widgets.js";
import { FeeSplittingClient } from "./modules/fee-splitting.js";
import { FundTokensClient } from "./modules/fund-tokens.js";
import { HolderRewardsClient } from "./modules/holder-rewards.js";
import { LendingClient } from "./modules/lending.js";
import { LimitOrdersClient } from "./modules/limit-orders.js";
import { LiveChatClient } from "./modules/live-chat.js";
import { StakingClient } from "./modules/staking.js";
import { PerpsClient } from "./modules/perps.js";
import { PointsSystemClient } from "./modules/points-system.js";
import { PredictionClient } from "./modules/prediction.js";
import { PremiumClient } from "./modules/premium.js";
import { PriceAlertsClient } from "./modules/price-alerts.js";
import { RaffleClient } from "./modules/raffle.js";
import { ReferralClient } from "./modules/referral.js";
import { ReputationClient } from "./modules/reputation.js";
import { SeasonsClient } from "./modules/seasons.js";
import { ShareCardsClient } from "./modules/share-cards.js";
import { SocialLaunchClient } from "./modules/social-launch.js";
import { StablePairsClient } from "./modules/stable-pairs.js";
import { TokenChatClient } from "./modules/token-chat.js";
import { TokenVideosClient } from "./modules/token-videos.js";
import { VotingClient } from "./modules/voting.js";

/**
 * Unified SDK entry-point for the SendIt 5IVE protocol.
 * All 31 module clients are accessible as properties.
 */
export class SenditSDK {
  private _handle: ProgramHandle;

  /** achievements.v — badge & milestone tracking */
  readonly achievements: AchievementsClient;
  /** airdrops.v — token airdrop campaigns */
  readonly airdrops: AirdropsClient;
  /** analytics.v — on-chain token analytics & whale tracking */
  readonly analytics: AnalyticsClient;
  /** bridge.v — cross-chain bridge via Wormhole */
  readonly bridge: BridgeClient;
  /** content_claims.v — content IP claims & verification */
  readonly contentClaims: ContentClaimsClient;
  /** copy_trading.v — leader/follower copy trading */
  readonly copyTrading: CopyTradingClient;
  /** creator_dashboard.v — creator analytics snapshots */
  readonly creatorDashboard: CreatorDashboardClient;
  /** custom_pages.v — custom token pages */
  readonly customPages: CustomPagesClient;
  /** daily_rewards.v — check-in & trade reward points */
  readonly dailyRewards: DailyRewardsClient;
  /** embeddable_widgets.v — embeddable chart/widget configs */
  readonly embeddableWidgets: EmbeddableWidgetsClient;
  /** fee_splitting.v — configurable fee splits */
  readonly feeSplitting: FeeSplittingClient;
  /** fund_tokens.v — on-chain index funds */
  readonly fundTokens: FundTokensClient;
  /** holder_rewards.v — holder reward pools */
  readonly holderRewards: HolderRewardsClient;
  /** lending.v — collateralised lending */
  readonly lending: LendingClient;
  /** limit_orders.v — on-chain limit orders */
  readonly limitOrders: LimitOrdersClient;
  /** live_chat.v — token live chat rooms */
  readonly liveChat: LiveChatClient;
  /** main.v — staking pools */
  readonly staking: StakingClient;
  /** perps.v — perpetual futures */
  readonly perps: PerpsClient;
  /** points_system.v — gamified points & seasons */
  readonly pointsSystem: PointsSystemClient;
  /** prediction.v — prediction markets */
  readonly prediction: PredictionClient;
  /** premium.v — premium listings */
  readonly premium: PremiumClient;
  /** price_alerts.v — on-chain price alerts */
  readonly priceAlerts: PriceAlertsClient;
  /** raffle.v — token raffles */
  readonly raffle: RaffleClient;
  /** referral.v — referral tracking & rewards */
  readonly referral: ReferralClient;
  /** reputation.v — FairScore reputation */
  readonly reputation: ReputationClient;
  /** seasons.v — season passes & XP */
  readonly seasons: SeasonsClient;
  /** share_cards.v — shareable token cards */
  readonly shareCards: ShareCardsClient;
  /** social_launch.v — tweet-verified token launches */
  readonly socialLaunch: SocialLaunchClient;
  /** stable_pairs.v — stablecoin AMM pairs */
  readonly stablePairs: StablePairsClient;
  /** token_chat.v — per-token chat */
  readonly tokenChat: TokenChatClient;
  /** token_videos.v — token video posts & voting */
  readonly tokenVideos: TokenVideosClient;
  /** voting.v — on-chain governance */
  readonly voting: VotingClient;

  constructor(config: SenditSDKConfig) {
    this._handle = new ProgramHandle(config);

    this.achievements = new AchievementsClient(this._handle);
    this.airdrops = new AirdropsClient(this._handle);
    this.analytics = new AnalyticsClient(this._handle);
    this.bridge = new BridgeClient(this._handle);
    this.contentClaims = new ContentClaimsClient(this._handle);
    this.copyTrading = new CopyTradingClient(this._handle);
    this.creatorDashboard = new CreatorDashboardClient(this._handle);
    this.customPages = new CustomPagesClient(this._handle);
    this.dailyRewards = new DailyRewardsClient(this._handle);
    this.embeddableWidgets = new EmbeddableWidgetsClient(this._handle);
    this.feeSplitting = new FeeSplittingClient(this._handle);
    this.fundTokens = new FundTokensClient(this._handle);
    this.holderRewards = new HolderRewardsClient(this._handle);
    this.lending = new LendingClient(this._handle);
    this.limitOrders = new LimitOrdersClient(this._handle);
    this.liveChat = new LiveChatClient(this._handle);
    this.staking = new StakingClient(this._handle);
    this.perps = new PerpsClient(this._handle);
    this.pointsSystem = new PointsSystemClient(this._handle);
    this.prediction = new PredictionClient(this._handle);
    this.premium = new PremiumClient(this._handle);
    this.priceAlerts = new PriceAlertsClient(this._handle);
    this.raffle = new RaffleClient(this._handle);
    this.referral = new ReferralClient(this._handle);
    this.reputation = new ReputationClient(this._handle);
    this.seasons = new SeasonsClient(this._handle);
    this.shareCards = new ShareCardsClient(this._handle);
    this.socialLaunch = new SocialLaunchClient(this._handle);
    this.stablePairs = new StablePairsClient(this._handle);
    this.tokenChat = new TokenChatClient(this._handle);
    this.tokenVideos = new TokenVideosClient(this._handle);
    this.voting = new VotingClient(this._handle);
  }

  /** Access the underlying ProgramHandle (for advanced use). */
  get handle(): ProgramHandle {
    return this._handle;
  }
}

// Re-exports
export { ProgramHandle, type SenditSDKConfig } from "./base.js";
export type { Address } from "./types.js";
export * from "./modules/achievements.js";
export * from "./modules/airdrops.js";
export * from "./modules/analytics.js";
export * from "./modules/bridge.js";
export * from "./modules/content-claims.js";
export * from "./modules/copy-trading.js";
export * from "./modules/creator-dashboard.js";
export * from "./modules/custom-pages.js";
export * from "./modules/daily-rewards.js";
export * from "./modules/embeddable-widgets.js";
export * from "./modules/fee-splitting.js";
export * from "./modules/fund-tokens.js";
export * from "./modules/holder-rewards.js";
export * from "./modules/lending.js";
export * from "./modules/limit-orders.js";
export * from "./modules/live-chat.js";
export * from "./modules/staking.js";
export * from "./modules/perps.js";
export * from "./modules/points-system.js";
export * from "./modules/prediction.js";
export * from "./modules/premium.js";
export * from "./modules/price-alerts.js";
export * from "./modules/raffle.js";
export * from "./modules/referral.js";
export * from "./modules/reputation.js";
export * from "./modules/seasons.js";
export * from "./modules/share-cards.js";
export * from "./modules/social-launch.js";
export * from "./modules/stable-pairs.js";
export * from "./modules/token-chat.js";
export * from "./modules/token-videos.js";
export * from "./modules/voting.js";
