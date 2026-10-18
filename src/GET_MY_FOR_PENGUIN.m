% ========================================================================
% Documentation reviewed: 2026-10-18 | Batch 01
% Purpose: Compute a depth-change rate series from a sampled depth record.
% Interface: l is series length; depth is depth vector; t is the time-step divisor.
% Review note: First output sample is initialized to zero; no assumptions changed.
% Scope: Documentation only; all pre-existing lines remain unchanged.
% ========================================================================

% ============================================================
% Documentation review: 2026-10-18 | Batch 01
% Scope: Review tracking header only; original code preserved.
% Numerical calculations, logic, and existing comments unchanged.
% ============================================================
function my=GET_MY_FOR_PENGUIN(l,depth,t); 
% Numerical interpretation: the first derivative sample is set to zero;
% subsequent values use successive depth differences divided by t.
my=zeros(l,1);

for i=2:l
   my(i)=(depth(i)-depth(i-1))/t;
end
return